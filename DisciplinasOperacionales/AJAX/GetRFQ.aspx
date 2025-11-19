=<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.Net.Mail" %>
<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="OfficeOpenXml" %>
<%@ Import Namespace="OfficeOpenXml.Style" %>

<script runat="server">
    public class RFQRequest
    {
        public string Netid { get; set; }
        public int operation { get; set; }
        public string Order_ID { get; set; }
        public string RFQ_Number { get; set; }
        public string PO_Number { get; set; }
        public string Status { get; set; }
        public string Emails { get; set; }
        public string Mensaje { get; set; }
        public string PAR { get; set; }
        public string T_Price { get; set; }
    }

    public class RFQItem
    {
        public int Id { get; set; }
        public string Netid { get; set; }
        public decimal T_Price { get; set; }
        public DateTime D_Created { get; set; }
        public DateTime? D_Closed { get; set; }
        public string RFQ_Number { get; set; }
        public string RFQ_Link { get; set; }
        public string PO_Number { get; set; }
        public bool Active { get; set; }
        public string L1_buyer { get; set; }
        public string L2_buyer { get; set; }
        public string Vendor { get; set; }
        public DateTime T_Stamp { get; set; }
        public string PAR { get; set; }
        public string rfqDescription { get; set; }
        public string Currency { get; set; }
        public string Status { get; set; }
    }
    string connStr = "Server=mxchlac-sql04;Database=LAIMS;User Id=sqlIIT;Password=Le@r2025!iitdata;";
    string rfqDescription = "", vendor;
    decimal totalOrden = 0;

    protected void Page_Load(object sender, EventArgs e)
    {
        string jsonInput;
        using (var reader = new StreamReader(Request.InputStream))
        {
            jsonInput = reader.ReadToEnd();
        }

        RFQRequest request = JsonConvert.DeserializeObject<RFQRequest>(jsonInput);

        if (request.operation == 0)
        {
            List<RFQItem> rfqs = new List<RFQItem>();

            

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = @"
                    SELECT TOP (1000) [Id], [Netid], [T_Price], [D_Created], [D_Closed], [RFQ_Number],
                           [RFQ_Link], [PO_Number], [Active], [L1_buyer], [L2_buyer], [Vendor],
                           [T_Stamp], ISNULL([PAR], 'NA') AS PAR, [rfqDescription],(Select top 1 Currency From LAIMS.dbo.RFQ_Items where Order_ID = A.id) As Currency
                           , ISNULL(Status, 'Pending') AS Status
                    FROM [LAIMS].[dbo].[RFQ_Requests] A
                    ORDER BY ID DESC";

                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@Netid", request.Netid);

                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    rfqs.Add(new RFQItem
                    {
                        Id = Convert.ToInt32(reader["Id"]),
                        Netid = reader["Netid"].ToString(),
                        T_Price = Convert.ToDecimal(reader["T_Price"]),
                        D_Created = Convert.ToDateTime(reader["D_Created"]),
                        D_Closed = reader["D_Closed"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(reader["D_Closed"]),
                        RFQ_Number = reader["RFQ_Number"].ToString(),
                        RFQ_Link = reader["RFQ_Link"].ToString(),
                        PO_Number = reader["PO_Number"].ToString(),
                        Active = Convert.ToBoolean(reader["Active"]),
                        L1_buyer = reader["L1_buyer"].ToString(),
                        L2_buyer = reader["L2_buyer"].ToString(),
                        Vendor = reader["Vendor"].ToString(),
                        T_Stamp = Convert.ToDateTime(reader["T_Stamp"]),
                        PAR = reader["PAR"].ToString(),
                        rfqDescription = reader["rfqDescription"].ToString(),
                        Currency = reader["Currency"].ToString(),
                        Status = reader["Status"].ToString()
                    });
                }
                conn.Close();
            }

            string jsonOutput = JsonConvert.SerializeObject(rfqs);
            Response.ContentType = "application/json";
            Response.Write(jsonOutput);
            Response.End();
        } else if (request.operation == 1)
        {
            string orderId = request.Order_ID;
            if (string.IsNullOrEmpty(orderId))
            {
                Response.StatusCode = 400;
                Response.Write("{\"error\":\"Order_ID es requerido\"}");
                Response.End();
                return;
            }

            var rfqDetail = new Dictionary<string, object>();
            var itemsList = new List<Dictionary<string, object>>();

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // Obtener RFQ principal
                string rfqQuery = @"
                    SELECT TOP (1) [Id], [Netid], [T_Price], [D_Created], [D_Closed], [RFQ_Number],
                        [RFQ_Link], [PO_Number], [Active], [L1_buyer], [L2_buyer], [Vendor],
                        [T_Stamp], ISNULL([PAR], 'NA') AS PAR, [rfqDescription],(Select top 1 Currency From LAIMS.dbo.RFQ_Items where Order_ID = A.id) As Currency
                        ,ISNULL(Status, 'Pending') AS Status
                    FROM [LAIMS].[dbo].[RFQ_Requests] A
                    WHERE Id = @Order_ID";

                using (SqlCommand cmd = new SqlCommand(rfqQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@Order_ID", orderId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            for (int i = 0; i < reader.FieldCount; i++)
                            {
                                rfqDetail[reader.GetName(i)] = reader[i];
                            }
                        }
                    }
                }

                // Obtener artículos
                string itemsQuery = @"
                    SELECT [Id], [Qty], [UM], [Currency], [Part_Num], [Brand], [Model],
                        [Description], [U_Price], [T_Price], [Link], [Order_ID], [T_Stamp]
                    FROM [LAIMS].[dbo].[RFQ_Items]
                    WHERE Order_ID = @Order_ID
                    ORDER BY Id ASC";

                using (SqlCommand cmd = new SqlCommand(itemsQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@Order_ID", orderId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            var item = new Dictionary<string, object>();
                            for (int i = 0; i < reader.FieldCount; i++)
                            {
                                item[reader.GetName(i)] = reader[i];
                            }
                            itemsList.Add(item);
                        }
                    }
                }
                conn.Close();
            }

            rfqDetail["items"] = itemsList;

            string jsonOutput = JsonConvert.SerializeObject(rfqDetail);
            Response.ContentType = "application/json";
            Response.Write(jsonOutput);
            Response.End();
        } else if (request.operation == 2)
        {
           
            string netid = request.Netid;
            string orderId = request.Order_ID;
            string status = request.Status;
            string rfqNumber = request.RFQ_Number;
            string poNumber = request.PO_Number;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string updateQuery = @"
                    UPDATE [LAIMS].[dbo].[RFQ_Requests]
                    SET 
                        RFQ_Number = @RFQ_Number,
                        PO_Number = @PO_Number,
                        Status = @Status
                    WHERE Id = @Order_ID";

                SqlCommand cmd = new SqlCommand(updateQuery, conn);
                cmd.Parameters.AddWithValue("@RFQ_Number", rfqNumber ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@PO_Number", poNumber ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@Status", status ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@Order_ID", orderId);

                conn.Open();
                int rowsAffected = cmd.ExecuteNonQuery();

                var result = new
                {
                    success = rowsAffected > 0,
                    message = rowsAffected > 0 ? "RFQ actualizada correctamente." : "No se encontró la RFQ para actualizar."
                };

                string jsonOutput = JsonConvert.SerializeObject(result);
                Response.ContentType = "application/json";
                Response.Write(jsonOutput);
                Response.End();
                conn.Close();
            }
        } else if (request.operation == 3)
        {
            string netid = request.Netid;
            string orderId = request.Order_ID;
            string EmailsCsv = request.Emails;
            string PAR = request.PAR;
            string costoTotal = request.T_Price;
            string status = request.Status;


            if (string.IsNullOrEmpty(orderId))
            {
                Response.StatusCode = 400;
                Response.Write("{\"error\":\"Order_ID es requerido\"}");
                Response.End();
                return;
            }

            var rfqDetail = new Dictionary<string, object>();
            var itemsList = new List<Dictionary<string, object>>();

             // Obtener artículos
                string itemsQuery = @"
                    SELECT [Id], [Qty], [UM], [Currency], [Part_Num], [Brand], [Model],
                        [Description], [U_Price], [T_Price], [Link], [Order_ID], [T_Stamp]
                    FROM [LAIMS].[dbo].[RFQ_Items]
                    WHERE Order_ID = @Order_ID
                    ORDER BY Id ASC";

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(itemsQuery, conn);
                 cmd.Parameters.AddWithValue("@Order_ID", orderId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            var item = new Dictionary<string, object>();
                            for (int i = 0; i < reader.FieldCount; i++)
                            {
                                item[reader.GetName(i)] = reader[i];
                            }
                            itemsList.Add(item);
                        }
                    }
                conn.Close();
            }

            // Construcci&oacute;n del correo
            string nombre = status.Contains("Financial") ? "Tania" : "Mario";
            string cuerpo = GenerarMensajeHTML(nombre, costoTotal,PAR);

            

            
                
                foreach (Dictionary<string, object> item in itemsList)
                {
                    cuerpo += "<tr>";
                    cuerpo += "<td>" + item["Qty"] + "</td>";
                    cuerpo += "<td>" + item["UM"] + "</td>";
                    cuerpo += "<td>" + item["Description"] + "</td>";
                    cuerpo += "<td>" + item["Part_Num"] + "</td>";
                    cuerpo += "<td>" + item["Brand"] + "</td>";
                    cuerpo += "<td>" + item["Model"] + "</td>";
                    cuerpo += "<td>" + item["U_Price"] + " " + item["Currency"] + "</td>";
                    cuerpo += "<td>" + item["T_Price"] + " " + item["Currency"] + "</td>";
                    cuerpo += "<td><a href='" + item["Link"] + "' target='_blank'>Ver artículo</a></td>";
                    cuerpo += "</tr>";
                }

                

            cuerpo += @"</tbody></table>
                <div class='footer'>
                    <p>Gracias por tu apoyo.</p>
                    <p>Atentamente,<br><strong>Equipo de Automatizaci&oacute;n</strong></p>
                </div></body></html>";

            MailMessage mail = new MailMessage();
            mail.From = new MailAddress("jcordoba01@lear.com");
            mail.To.Add("jcordoba01@lear.com");
            mail.Subject = "Solicitud de Compra para Coupa AI " + int.Parse(orderId).ToString("0000");
            mail.Body =cuerpo;
            mail.IsBodyHtml = true;

            // Adjuntar al correo
                Attachment excelAttachment = new Attachment(GenerateExcelStream(itemsList), "Requisicion_" + int.Parse(orderId).ToString("0000") + ".xlsx", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
                mail.Attachments.Add(excelAttachment);

            SmtpClient smtp = new SmtpClient("smtp.lear.com", 25);
            smtp.Credentials = new NetworkCredential("jcordoba01@lear.com", "Redento1.0Redento");
            smtp.EnableSsl = true;
            smtp.Send(mail);
            
            var result = new
                {
                    success = true,
                    message = true ? "Correo Enviado correctamente." : "No se encontró la RFQ para actualizar."
                };

                string jsonOutput = JsonConvert.SerializeObject(result);
                Response.ContentType = "application/json";
                Response.Write(jsonOutput);
                Response.End();
        } else if (request.operation == 4)
        {
            string orderId = request.Order_ID;
             using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = @"
                    DELETE FROM [LAIMS].[dbo].[RFQ_Requests] WHERE id = @Order_ID;
                    DELETE FROM [LAIMS].[dbo].[RFQ_Items] WHERE Order_ID = @Order_ID;";

                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@Order_ID", orderId);

                conn.Open();
                cmd.ExecuteReader();
                conn.Close();
            }
        }

    }

    private void StyleRange(ExcelWorksheet ws, string range, Font font, bool bold, ExcelHorizontalAlignment hAlign, ExcelVerticalAlignment vAlign, ExcelBorderStyle borderStyle, bool underline = false)
{
    var cells = ws.Cells[range];
    cells.Style.Font.Name = font.Name;
    cells.Style.Font.Size = font.Size;
    cells.Style.Font.Bold = bold;
    cells.Style.Font.UnderLine = underline;
    cells.Style.HorizontalAlignment = hAlign;
    cells.Style.VerticalAlignment = vAlign;
    cells.Style.WrapText = true;
    cells.Style.Border.BorderAround(borderStyle);
}


    

    public MemoryStream GenerateExcelStream(dynamic orden)
    {
        //ExcelPackage.LicenseContext = LicenseContext.NonCommercial;

        var stream = new MemoryStream();

        using (var package = new ExcelPackage())
        {
            var ws = package.Workbook.Worksheets.Add("Requisicion");
            ws.View.ShowGridLines = false;


            var titleFont = new Font("Bookman Old Style", 16, FontStyle.Bold);
            var headerFont = new Font("Bookman Old Style", 11, FontStyle.Bold);
            var normalFont = new Font("Bookman Old Style", 11);

            var center = ExcelHorizontalAlignment.Center;
            var middle = ExcelVerticalAlignment.Center;
            var thinBorder = ExcelBorderStyle.Thin;
            var thickBorder = ExcelBorderStyle.Thick;
            var DoubleBorder = ExcelBorderStyle.Double;

            double[] widths = { 3.5,8, 11, 12, 11, 11, 14, 45.86, 15, 20 };
            for (int i = 0; i < widths.Length; i++)
                ws.Column(i + 1).Width = widths[i];

            ws.Cells["B2:J2"].Merge = true;
            ws.Cells["B2"].Value = "FORMATO DE REQUISICION";
            StyleRange(ws, "B2:J2", titleFont, true, center, middle, DoubleBorder);

            ws.Cells["B3:C3"].Merge = true;
            ws.Cells["B3"].Value = "DESCRIPCION:";            
            ws.Cells["B3"].Style.Fill.PatternType = OfficeOpenXml.Style.ExcelFillStyle.Solid;
            ws.Cells["B3"].Style.Fill.BackgroundColor.SetColor(Color.LightGray);
            StyleRange(ws, "B3:C3", headerFont, true, center, middle, DoubleBorder);
            ws.Cells["I3:J3"].Merge = true;
            ws.Cells["I3"].Value = "FECHA:";
            ws.Cells["I3"].Style.Fill.PatternType = OfficeOpenXml.Style.ExcelFillStyle.Solid;
            ws.Cells["I3"].Style.Fill.BackgroundColor.SetColor(Color.LightGray);
            StyleRange(ws, "I3:J3", headerFont, true, center, middle, DoubleBorder);

            ws.Cells["B4:H6"].Merge = true;
            string texto = HttpUtility.HtmlDecode("Dise&ntilde;o y Fabricaci&oacute;n De Proyecto de Automatizaci&oacute;n");
            ws.Cells["B4"].Value = rfqDescription != "" ? rfqDescription : texto;
            StyleRange(ws, "B3:H6", normalFont, false, center, middle, DoubleBorder);

            ws.Cells["I4:J5"].Merge = true;
            ws.Cells["I4"].Value = "2025-08-25";
            StyleRange(ws, "I4:J5", normalFont, false, center, middle, DoubleBorder);

            ws.Cells["I6:J6"].Merge = true;
            ws.Cells["I6"].Value = "No. de control";
            ws.Cells["I6"].Style.Fill.PatternType = OfficeOpenXml.Style.ExcelFillStyle.Solid;
            ws.Cells["I6"].Style.Fill.BackgroundColor.SetColor(Color.LightGray);
            StyleRange(ws, "I6:J6", headerFont, true, center, middle, DoubleBorder);

            ws.Cells["B7:C7"].Merge = true;
            ws.Cells["B7"].Value = "DETALLES:";
            ws.Cells["B7"].Style.Fill.PatternType = OfficeOpenXml.Style.ExcelFillStyle.Solid;
            ws.Cells["B7"].Style.Fill.BackgroundColor.SetColor(Color.LightGray);
            StyleRange(ws, "B7:C7", headerFont, true, center, middle, DoubleBorder);

            ws.Cells["B8:H9"].Merge = true;
            ws.Cells["B8"].Value = "CATALOGO";
            StyleRange(ws, "B7:H9", headerFont, true, center, middle, DoubleBorder);

            ws.Cells["I7:J10"].Merge = true;
            StyleRange(ws, "I7:J10", headerFont, true, center, middle, DoubleBorder);

            ws.Cells["B10:C10"].Merge = true;
            ws.Cells["B10"].Value = "PROVEEDOR:";
            ws.Cells["B10"].Style.Fill.PatternType = OfficeOpenXml.Style.ExcelFillStyle.Solid;
            ws.Cells["B10"].Style.Fill.BackgroundColor.SetColor(Color.LightGray);
            StyleRange(ws, "B10:C10", headerFont, true, center, middle, DoubleBorder);

            ws.Cells["D10:H10"].Merge = true;
            ws.Cells["D10"].Value = vendor != "" ? vendor : "VARIOS";
            StyleRange(ws, "D10:H10", headerFont, true, center, middle, DoubleBorder);

            string[] headers = { "CANT", "U/M", "MONEDA", "# PARTE", "MARCA", "MODELO", "DESCRIPCION", "PRECIO UNITARIO", "PRECIO TOTAL" };
            for (int i = 0; i < headers.Length; i++)
            {
                ws.Cells[11, i + 2].Value = headers[i];
                StyleRange(ws, ws.Cells[11, i + 2].Address, headerFont, true, center, middle, DoubleBorder);
            }

            /*string json = new System.IO.StreamReader(HttpContext.Current.Request.InputStream).ReadToEnd();
            dynamic datos = JsonConvert.DeserializeObject(json);
            var orden = datos.orden;*/

            for (int row = 12; row < 33; row++)
            {
                int index = row - 12;
                
                if (orden != null && index >= 0 && index < orden.Count)
                {
                    var item = orden[index];
                    ws.Cells[row, 1].Value = row - 11;
                    ws.Cells[row, 2].Value = int.Parse(item["Qty"].ToString());
                    ws.Cells[row, 3].Value = item["UM"].Replace("'", "''");
                    ws.Cells[row, 4].Value = item["Currency"].Replace("'", "''");
                    ws.Cells[row, 5].Value = item["Part_Num"].Replace("'", "''");
                    ws.Cells[row, 6].Value = item["Brand"].Replace("'", "''");
                    ws.Cells[row, 7].Value = item["Model"].Replace("'", "''");
                    ws.Cells[row, 8].Value = item["Description"].Replace("'", "''");
                    ws.Cells[row, 9].Value = (decimal)item["U_Price"];
                    ws.Cells[row, 10].Value = (decimal)item["T_Price"];

                }
                for (int col = 2; col <= 10; col++)
                {
                    StyleRange(ws, ws.Cells[row, col].Address, normalFont, false, center, middle, thinBorder);
                }
            }

            
            StyleRange(ws, "B12:J32", headerFont, true, center, middle, DoubleBorder);

            ws.Cells["B33:D33"].Merge = true;
            ws.Cells["B33"].Value = "DEPARTAMENTO:";
            ws.Cells["E33:G33"].Merge = true;
            ws.Cells["E33"].Value = "Automation & Innovation";
            ws.Cells["I33"].Value = "TOTAL :";
            StyleRange(ws, "J33", headerFont, true, center, middle, DoubleBorder);
            var cell = ws.Cells["J33"];
            cell.Value = totalOrden; // o null si quieres que se vea como "$ -"
            cell.Style.Numberformat.Format = "$ #,##0.00;\\-\\$ #,##0.00";

            ws.Cells["B34:D34"].Merge = true;
            ws.Cells["B34"].Value = "MATERIAL REQUERIDO POR:";
            ws.Cells["F34:G34"].Merge = true;
            ws.Cells["F34"].Value = "Angel Cordoba";

            ws.Cells["B36:D36"].Merge = true;
            ws.Cells["B36"].Value = "SUPERVISOR GENERAL :";
            ws.Cells["F36:G36"].Merge = true;
            ws.Cells["F36"].Value = "Angel Cordoba";

            ws.Cells["B38:E38"].Merge = true;
            ws.Cells["B38"].Value = "AUTORIZO GERENTE DE DEPTO:";
            ws.Cells["F38:G38"].Merge = true;
            ws.Cells["F38"].Value = "Marco Leyva";

            /*foreach (int row in new[] { 32, 33, 35, 37 })
            {
                foreach (int col in new[] { 2, 6, 9, 10 })
                {
                    StyleRange(ws, ws.Cells[row, col].Address, headerFont, true, center, middle, thinBorder);
                }
            }*/

            
            StyleRange(ws, "B33:J39", headerFont, true, center, middle, DoubleBorder, true);

            package.SaveAs(stream);
        }

        stream.Position = 0;
        return stream;
    }

    public string GenerarMensajeHTML(string nombre, string costoTotal, string par)
{
    Dictionary<int, string> mensajes = new Dictionary<int, string>
    {
        { 1, "Espero que estés teniendo un excelente día. ¿Podrías ayudarnos revisando esta solicitud cuando tengas oportunidad?" },
        { 2, "Confío en que todo va bien. ¿Nos podrías apoyar con la validación de esta requisición, por favor?" },
        { 3, "Buen día, ¿serías tan amable de ayudarnos con la revisión de esta solicitud de compra?" },
        { 4, "Hola, espero que estés bien. ¿Nos podrías apoyar con esta requisición para continuar con el proceso?" },
        { 5, "¿Podrías por favor ayudarnos a revisar esta solicitud? Agradecemos mucho tu apoyo." },
        { 6, "Buen día, ¿nos podrías ayudar con la autorización de esta compra? Gracias de antemano." },
        { 7, "¿Podrías darnos una mano revisando esta requisición? Tu apoyo es muy valioso para nosotros." },
        { 8, "Espero que estés teniendo una buena jornada. ¿Nos ayudas con esta solicitud, por favor?" },
        { 9, "¿Podrías ayudarnos a validar esta requisición para poder continuar con el proceso de compra?" },
        { 10, "Hola, ¿nos podrías apoyar revisando esta solicitud? Agradecemos mucho tu tiempo." },
        { 11, "Buen día, ¿serías tan amable de revisar esta requisición cuando tengas un espacio?" },
        { 12, "¿Nos podrías ayudar con esta solicitud? Es importante para avanzar con el proceso de adquisición." },
        { 13, "Hola, ¿podrías por favor revisar esta requisición? Tu apoyo es muy importante para nosotros." },
        { 14, "¿Nos ayudas con la validación de esta solicitud? Agradecemos mucho tu colaboración." },
        { 15, "Buen día, ¿podrías ayudarnos con esta requisición? Es parte de un proceso urgente." },
        { 16, "¿Podrías revisar esta solicitud cuando tengas oportunidad? Gracias por tu apoyo." },
        { 17, "Hola, ¿nos podrías apoyar con esta requisición? Agradecemos mucho tu tiempo y disposición." },
        { 18, "¿Podrías ayudarnos con la revisión de esta solicitud? Es importante para continuar con el proceso." },
        { 19, "Buen día, ¿nos podrías apoyar revisando esta requisición? Gracias por tu colaboración." },
        { 20, "¿Podrías por favor validar esta solicitud? Agradecemos mucho tu ayuda." },
        { 21, "Hola, ¿nos ayudas con esta requisición? Tu apoyo es clave para avanzar." },
        { 22, "¿Podrías revisar esta solicitud cuando tengas un momento? Muchas gracias." },
        { 23, "Buen día, ¿nos podrías apoyar con esta requisición? Agradecemos tu tiempo." },
        { 24, "¿Podrías ayudarnos con esta solicitud? Es parte de un proceso que necesitamos cerrar pronto." },
        { 25, "Hola, ¿nos podrías apoyar revisando esta requisición? Gracias por tu atención." },
        { 26, "¿Podrías ayudarnos con esta solicitud? Tu apoyo es muy importante para nosotros." },
        { 27, "Buen día, ¿nos podrías apoyar con esta requisición? Agradecemos mucho tu ayuda." },
        { 28, "¿Podrías revisar esta solicitud por favor? Es parte de un proceso prioritario." },
        { 29, "Hola, ¿nos podrías ayudar con esta requisición? Gracias por tu colaboración." },
        { 30, "¿Podrías apoyarnos con la validación de esta solicitud? Agradecemos mucho tu tiempo." },
        { 31, "Buen día, ¿nos podrías ayudar con esta requisición? Tu apoyo es muy valioso para nosotros." }
    };

    int dia = DateTime.Now.Day;
    string mensaje = mensajes.ContainsKey(dia) ? mensajes[dia] : "¿Nos podrías ayudar con esta solicitud, por favor?";

    string cuerpo = "<html><head><style>" +
    "body { font-family: Arial, sans-serif; color: #333; }" +
    "table { width: 100%; border-collapse: collapse; margin-top: 20px; }" +
    "th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }" +
    "th { background-color: #f2f2f2; }" +
    ".footer { margin-top: 30px; }" +
    "</style></head><body>" +
    string.Format("<p>Hola {0},</p><p>{1}</p><p>El costo total de esta solicitud es de: <strong>{2:C}</strong>.</p>", nombre, mensaje, costoTotal);


    if (!string.IsNullOrWhiteSpace(par))
    {
        cuerpo += string.Format("<p>El PAR asignado para esta compra es: <strong>{0}</strong>.</p>", par);

    }

    cuerpo += "<table><thead><tr>" +
              "<th>Cantidad</th><th>Unidad</th><th>Descripción</th><th>Parte</th><th>Marca</th><th>Modelo</th><th>Precio Unitario</th><th>Total</th><th>Link</th>" +
              "</tr></thead><tbody>";

    return cuerpo;
}

</script>
