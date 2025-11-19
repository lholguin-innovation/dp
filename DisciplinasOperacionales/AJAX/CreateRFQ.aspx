<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.Net.Mail" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="OfficeOpenXml" %>
<%@ Import Namespace="OfficeOpenXml.Style" %>


<script runat="server">
    
    decimal totalOrden = 0;
    int orderId = 0;
    string PAR = "";
    string vendor = "";
    string rfqDescription = "";
    string buyerEmail = "";
    public class Respuesta
    {
        public string status { get; set; }
        public string message { get; set; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
           string json = new System.IO.StreamReader(Request.InputStream).ReadToEnd();
           dynamic datos = JsonConvert.DeserializeObject(json);
           string fecha = datos.fecha;
            var orden = datos.orden;
            PAR = datos.PAR;
            vendor = datos.vendor.ToString();
            rfqDescription = datos.rfqDescription.ToString();
            buyerEmail = datos.Buyer;
            
            foreach (var item in orden)
            {
                decimal precioTotal;
                if (decimal.TryParse((string)item.precioTotal.ToString().Replace("$", "").Replace(",", "").Trim(), out precioTotal))
                {
                    totalOrden += precioTotal;
                }
            }

           
            string connectionString = "Server=mxchlac-sql04;Database=LAIMS;User Id=sqlIIT;Password=Le@r2025!iitdata;";
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                string insertOrder = "INSERT INTO dbo.RFQ_Requests (T_Price, D_Created, Vendor, rfqDescription, L1_buyer, PAR, Netid) OUTPUT INSERTED.Id VALUES (@T_Price, @D_Created, @Vendor, @rfqDescription, @L1_Buyer, @PAR, 'JCORDOBA01')";
                using (SqlCommand cmd = new SqlCommand(insertOrder, conn))
                {
                    cmd.Parameters.AddWithValue("@T_Price", totalOrden);
                    cmd.Parameters.AddWithValue("@D_Created", DateTime.Parse(fecha));
                    cmd.Parameters.AddWithValue("@Vendor", vendor);
                    cmd.Parameters.AddWithValue("@rfqDescription", rfqDescription);
                    cmd.Parameters.AddWithValue("@L1_Buyer", buyerEmail);
                    cmd.Parameters.AddWithValue("@PAR", PAR);
                    orderId = (int)cmd.ExecuteScalar();
                }

                string insertItemTemplate = @"
                INSERT INTO dbo.RFQ_Items 
                (Qty, UM, Currency, Part_Num, Model, Description, U_Price, T_Price, Link, Order_ID, Brand) 
                VALUES ({0}, '{1}', '{2}', '{3}', '{4}', '{5}', {6}, {7}, '{8}', {9}, '{10}')";

                foreach (var item in orden)
                {
                    string insertItem = string.Format(insertItemTemplate,
                        (int)item.cantidad,
                        item.unidad.ToString().Replace("'", "''"),
                        item.moneda.ToString().Replace("'", "''"),
                        item.parte.ToString().Replace("'", "''"),
                        item.Model.ToString().Replace("'", "''"),
                        item.descripcion.ToString().Replace("'", "''"),
                        decimal.Parse(item.precioUnitario.ToString().Replace("$", "").Replace(",", "").Trim(), System.Globalization.CultureInfo.InvariantCulture),
                        decimal.Parse(item.precioTotal.ToString().Replace("$", "").Replace(",", "").Trim(), System.Globalization.CultureInfo.InvariantCulture),
                        item.link.ToString().Replace("'", "''"),
                        orderId, item.Brand.ToString().Replace("'", "''")
                    );

                    using (SqlCommand cmd = new SqlCommand(insertItem, conn))
                    {
                        cmd.ExecuteNonQuery();
                    }
                }
                conn.Close();
            }

            // Crear archivo Excel desde plantilla



            // Construcci&oacute;n del correo
            string cuerpo = @"<html><head><style>
                body { font-family: Arial, sans-serif; color: #333; }
                table { width: 100%; border-collapse: collapse; margin-top: 20px; }
                th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
                th { background-color: #f2f2f2; }
                .footer { margin-top: 30px; }
            </style></head><body>
                <p>Hola Tania Buenas tardes,</p>
                <p>Nos puedes ayudar por favor para revisar / autorizar esta requisici&oacute;n con los siguientes art&iacute;culos?</p>
                <table><thead><tr>
                    <th>Cantidad</th><th>Unidad</th><th>Descripci&oacute;n</th><th>Parte</th><th>Marca</th><th>Modelo</th><th>Precio Unitario</th><th>Total</th><th>Link</th>
                </tr></thead><tbody>";

            string cuerpo2 = @"<html><head><style>
                body { font-family: Arial, sans-serif; color: #333; }
                table { width: 100%; border-collapse: collapse; margin-top: 20px; }
                th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
                th { background-color: #f2f2f2; }
                .footer { margin-top: 30px; }
            </style></head><body>
                <p>Hola Mario buen día,</p>
                <p>Nos puedes ayudar por favor a requerir este material en Coupa? este es el PAR al que deben ser cargados los siguientes art&iacute;culos " + PAR + @"</p>
                <table><thead><tr>
                    <th>Cantidad</th><th>Unidad</th><th>Descripci&oacute;n</th><th>Parte</th><th>Marca</th><th>Modelo</th><th>Precio Unitario</th><th>Total</th><th>Link</th>
                </tr></thead><tbody>";

            foreach (var item in orden)
            {
                cuerpo += @"<tr>
                    <td>" + item.cantidad + @"</td>
                    <td>" + item.unidad + @"</td>
                    <td>" + item.descripcion + @"</td>
                    <td>" + item.parte + @"</td>
                    <td>" + item.Brand + @"</td>
                    <td>" + item.Model + @"</td>
                    <td>" + item.precioUnitario + " " + item.moneda + @"</td>
                    <td>" + item.precioTotal + @"</td>
                    <td><a href='" + item.link + @"' target='_blank'>Ver art&iacute;culo</a></td>
                </tr>";
            }

            foreach (var item in orden)
            {
                cuerpo2 += @"<tr>
                    <td>" + item.cantidad + @"</td>
                    <td>" + item.unidad + @"</td>
                    <td>" + item.descripcion + @"</td>
                    <td>" + item.parte + @"</td>
                    <td>" + item.Brand + @"</td>
                    <td>" + item.Model + @"</td>
                    <td>" + item.precioUnitario + " " + item.moneda + @"</td>
                    <td>" + item.precioTotal + @"</td>
                    <td><a href='" + item.link + @"' target='_blank'>Ver art&iacute;culo</a></td>
                </tr>";
            }

            cuerpo += @"</tbody></table>
                <div class='footer'>
                    <p>Gracias por tu apoyo.</p>
                    <p>Atentamente,<br><strong>Equipo de Automatizaci&oacute;n</strong></p>
                </div></body></html>";

            MailMessage mail = new MailMessage();
            mail.From = new MailAddress("jcordoba01@lear.com");
            mail.To.Add("jcordoba01@lear.com");
            mail.Subject = "Solicitud de Compra para Coupa AI" + orderId.ToString("0000");
            mail.Body = PAR != "" ? cuerpo2 : cuerpo;
            mail.IsBodyHtml = true;

            // Adjuntar al correo
                Attachment excelAttachment = new Attachment(GenerateExcelStream(orden), "Requisicion_" + orderId.ToString("0000") + ".xlsx", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
                mail.Attachments.Add(excelAttachment);

            SmtpClient smtp = new SmtpClient("smtp.lear.com", 25);
            smtp.Credentials = new NetworkCredential("jcordoba01@lear.com", "Redento2.0Redento");
            smtp.EnableSsl = true;
            smtp.Send(mail);

            Respuesta respuesta = new Respuesta
            {
                status = "OK",
                message = "Correo enviado y datos registrados correctamente."
            };

            Response.ContentType = "application/json";
            Response.Write(JsonConvert.SerializeObject(respuesta));
        }
        catch (Exception ex)
        {
         if (orderId > 0){
         string deleteOrder = @"Delete FROM [LAIMS].[dbo].[RFQ_Requests] WHERE id = {0};
                                Delete FROM [LAIMS].[dbo].[RFQ_Items] WHERE Order_ID = {0};";
        deleteOrder = String.Format(deleteOrder, orderId);
        string connectionString = "Server=mxchlac-sql04;Database=LAIMS;User Id=sqlIIT;Password=Le@r2025!iitdata;";
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(deleteOrder, conn))
                {
                    cmd.ExecuteScalar();
                }
            }
         }
            Respuesta error = new Respuesta
            {
                status = "Error",
                message = ex.Message
            };

            Response.ContentType = "application/json";
            Response.Write(JsonConvert.SerializeObject(error));
        }
        Response.End();
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
                    ws.Cells[row, 2].Value = (int)item.cantidad;
                    ws.Cells[row, 3].Value = item.unidad.ToString().Replace("'", "''");
                    ws.Cells[row, 4].Value = item.moneda.ToString().Replace("'", "''");
                    ws.Cells[row, 5].Value = item.parte.ToString().Replace("'", "''");
                    ws.Cells[row, 6].Value = item.Brand.ToString().Replace("'", "''");
                    ws.Cells[row, 7].Value = item.Model.ToString().Replace("'", "''");
                    ws.Cells[row, 8].Value = item.descripcion.ToString().Replace("'", "''");
                    ws.Cells[row, 9].Value = decimal.Parse(item.precioUnitario.ToString().Replace("$", "").Replace(",", "").Trim(), System.Globalization.CultureInfo.InvariantCulture);
                    ws.Cells[row, 10].Value = decimal.Parse(item.precioTotal.ToString().Replace("$", "").Replace(",", "").Trim(), System.Globalization.CultureInfo.InvariantCulture);
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
       
</script>
