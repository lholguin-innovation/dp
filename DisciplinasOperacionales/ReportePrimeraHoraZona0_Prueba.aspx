<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="ClosedXML.Excel" %>
<%@ Import Namespace="System.Net.Mail" %>
<%@ Import Namespace="System.Web.UI" %>

<script runat="server">
protected void Page_Load(object sender, EventArgs e)
{
    if (Request.HttpMethod == "GET")
    {
        //try
        //{
            string connectionStringEmpaques = "Server=USVIASH-DB05;Database=Empaques;User Id=apps;Password=99552499*;";
            string connectionStringUsuarios = "Server=USASHPMCIDB01;Database=DTv2;User Id=apps;Password=99552499*;";
            string fechaActual = !string.IsNullOrEmpty(Request["Fecha"]) ? Request["Fecha"].ToString() : DateTime.Now.ToString("yyyy-MM-dd");
            string Zona = Request["Zona"].ToString();
            string Turno = Request["Turno"].ToString();
            string Hora = Request["Hora"].ToString();
            string Titulo = Request["Titulo"].ToString();
            string queryLineas = "";
            string FechaQuery = "";
            int TestTrigger = Request["isTest"] != null ? Convert.ToInt32(Request["isTest"]) : 0;
            DateTime FechaRecibida = Request["Fecha"] != null ?  DateTime.Parse(Request["Fecha"].ToString()) : DateTime.Now;
            string MFG101Construct = "";

            // Lista para almacenar los destinatarios y la planta correspondiente
            Dictionary<string, List<string>> reportesEnviados = new Dictionary<string, List<string>>();
            // Lista para almacenar los registros de las plantas para insertar en Bulk
            Dictionary<int, List<Dictionary<string, object>>> datosPorPlanta = new Dictionary<int, List<Dictionary<string, object>>>();

            // Consulta para obtener correos de todos los usuarios con permiso FH & LH Turno A
            string queryUsuarios = TestTrigger == 1 ? "SELECT idplanta, Planta, Email FROM DTv2.dbo.Cat_Usuarios WHERE netid = 'mj2r9x';" :
            "SELECT idplanta, Planta, Email FROM DTv2.dbo.Cat_Usuarios WHERE Tipo_Admin LIKE '%FH & LH Turno " + Turno + "%';";
            Dictionary<int, List<string>> plantaEmails = GetEmailsByPlant(connectionStringUsuarios, queryUsuarios);

            // Primer query: Obtener la lista de plantas
            string queryPlantas = "SELECT id_planta, planta FROM [USASHPMCIDB01].[Catplantas].[dbo].[Cat_Plantas] WHERE id_planta NOT IN (16,20,22,25,26,27,28,29,30,33) AND zona_horaria = '" + Zona + "' ORDER BY id_planta";
            DataTable plantas = EjecutarQuery(connectionStringEmpaques, queryPlantas);

            foreach (DataRow planta in plantas.Rows)
            {
                int idPlanta = Convert.ToInt32(planta["id_planta"]);
                string nombrePlanta = planta["planta"].ToString();
                int contadorLineas = 0;
                double acumuladorPromedio = 0;
                double acumuladorPlan = 0;
                double acumuladorReal = 0;
                 // Acumulador de datos para esta planta
                 List<Dictionary<string, object>> registrosPlanta = new List<Dictionary<string, object>>();
                /*if (plantaEmails.ContainsKey(idPlanta) == false) //Para no procesar correos que no van a ser enviados
            {
                continue;
            }*/
            Hora = Request["Hora"].ToString(); // Para que regrese a su valor original en cada ciclo del for each
                if (Zona == "2" && Hora == "6" && idPlanta == 4) // Para Durango 1 que su primeroa hora es a las 7 am
                {
                    Hora = "7";
                }
                else if (Zona == "2" && Hora == "15" && idPlanta == 4) // Para Durango I que su ultima hora es 16
                {
                    Hora = "16";
                }
                else if (Hora == "0" && Turno == "B" && (idPlanta == 7 || idPlanta == 8)) //Para que a todos les cuente la ultima hora de 11 a 12 de la noche (23:00 a 00:00)
                {
                    Hora = "23";
                }
                else if (Turno == "B" && Hora == "15" && idPlanta == 8)
                {
                    Hora = "15,16";
                }
                

                // Segundo query: Obtener las líneas de producción
                queryLineas = "SELECT Alias, Linea, encendida_" + Turno + ", id FROM Empaques.dbo.codigos WHERE idPlanta = " + idPlanta + " AND hostname = 1 ORDER BY encendida_" + Turno + " DESC, Alias ASC";
                DataTable lineas = EjecutarQuery(connectionStringEmpaques, queryLineas);

                string tablaHTML = @"
                    <table border='1' cellpadding='5' cellspacing='0' style='width: 100%; border-collapse: collapse;'>
                        <tr>
                            <th>Nombre de la L&iacute;nea</th>
                            <th>Plan de Producci&oacute;n</th>
                            <th>Real de Producci&oacute;n</th>
                            <th>Diferencia</th>
                            <th>Estado</th>
                        </tr>";

                using (var workbook = new XLWorkbook())
                {
                    var worksheet = workbook.Worksheets.Add("REPORTE " + Titulo + " TURNO " + Turno);

                    worksheet.Cell(1, 1).Value = "NOMBRE DE LA LINEA";
                    worksheet.Cell(1, 2).Value = "PLAN DE PRODUCCION";
                    worksheet.Cell(1, 3).Value = "REAL DE PRODUCCION";
                    worksheet.Cell(1, 4).Value = "DIFERENCIA";
                    worksheet.Cell(1, 5).Value = "ESTADO";
                    worksheet.Cell(1, 6).Value = "MFG 101";


                    int row = 2;
                    foreach (DataRow linea in lineas.Rows)
                    {                  

                        string aliasLinea = linea["Alias"].ToString();
                        string nombreLinea = linea["Linea"].ToString();
                        int encendidaA = Convert.ToInt32(linea["encendida_" + Turno]);
                        string estado = "LINEA NO ACTIVA";
                        string colorHTML = "style='background-color:lightgrey'";
                        double plan = 0, real = 0, diferencia = 0;
                        string idAlias = linea["id"].ToString();
                        
                        
                        if (Turno == "B" && Titulo.Contains("Ultima") && (Hora == "0" || Hora == "23"))
                            {
                                FechaQuery = FechaRecibida.AddDays(-1).ToString("yyyy-MM-dd");      
                                //FechaRecibida = FechaRecibida.AddDays(-1);                  
                            }
                            else
                            {
                                FechaQuery = FechaRecibida.ToString("yyyy-MM-dd");
                            }
                    
                        if (encendidaA == 1)
                        {
                            string queryPlan = "";
                            string queryReal = "";
                            string Tabla = "productos_RT";
                            try
                            {
                            queryPlan = "SELECT TOP 1 Linea, Cantidad FROM Empaques.dbo.Programado WHERE idPlanta = " + idPlanta + " AND fecha = '" + FechaQuery + "' AND turno = '" + Turno + "' AND hora in (" + Hora + ") AND Linea = '" + nombreLinea + "'";
                            DataTable planProduccion = EjecutarQuery(connectionStringEmpaques, queryPlan);

                            for (int i=0; i<=1;i++)
                            {
                                queryReal = "SELECT ISNULL(sum(Cantidad),0) as Cantidad FROM Empaques.dbo." + Tabla + " WHERE idPlanta = " + idPlanta + " AND fecha = '" + FechaQuery + "' AND turno = '" + Turno + "' AND Linea = '" + nombreLinea + "' AND Hora in (" + Hora + ")";
                                if(idPlanta == 7) {Response.Write(queryReal + "<br>");}
                                DataTable realProduccion = EjecutarQuery(connectionStringEmpaques, queryReal);
                                real = realProduccion.Rows.Count > 0 ? Convert.ToDouble(realProduccion.Rows[0]["Cantidad"]) : 0;
                                if(idPlanta == 7) {Response.Write("Resultado de " + Tabla + "= " + real + "<br>");}
                                if (real == 0) {Tabla = "Productos";} else {break;} //Para romper el ciclo en caso de que si haya piezas en productos_RT
                            }

                            plan = planProduccion.Rows.Count > 0 ? Convert.ToDouble(planProduccion.Rows[0]["Cantidad"]) : 0;                            
                            diferencia = real - plan;

                            string queryMFG101 = "Select fase, nombre FROM [DTv2].[dbo].[MFG1O1_Bitacora] "
                                                + "where idPlanta = " + idPlanta + " and turno = '" + Turno + "' and status = 'COMPLETA' "
                                                + "and Cast(fh as date) = '" + FechaQuery + "' and idAlias = " + idAlias + " ORDER BY id asc";
                            DataTable dtMFG101 = EjecutarQuery(connectionStringEmpaques,queryMFG101);

                            bool ET1 = false, ET2 = false, ET3 = false, ET4 = false;
                            
                            if (dtMFG101.Rows.Count > 0)
                            {
                                foreach (DataRow r in dtMFG101.Rows)
                                {
                                    switch(r["fase"].ToString()) 
                                    {
                                    case "AT":
                                        ET1 = 1;
                                        break;
                                    case "IT":
                                        ET2 = 1;
                                        break;
                                    case "DT":
                                        ET3 = 1;
                                        break;
                                    case "FT":
                                        ET4 = 1;
                                        break;                                    
                                    }
                                }
                            } //☑ ☒ ✖
                            MFG101Construct = "Antes (" + ET1 == 1 ? "✓" : "✖" + ") Inicio (" + ET2 == 1 ? "✓" : "✖" + ") Durante (" + ET3 == 1 ? "✓" : "✖" + ") Final (" + ET4 == 1 ? "✓" : "✖" + ")";

                            if (plan == 0)
                            {
                                estado = "Sin Plan";
                                colorHTML = "style='background-color:lightgrey'";
                            }
                            else if (real >= plan)
                            {
                                estado = (real / plan * 100).ToString("0.00") + "%";
                                colorHTML = "style='background-color:lightgreen'";
                                contadorLineas++;
                                acumuladorPromedio += (real / plan * 100);
                                acumuladorPlan += plan;
                                acumuladorReal += real;
                            }
                            else
                            {
                                estado = (real / plan * 100).ToString("0.00") + "%";
                                colorHTML = "style='background-color:lightcoral'";
                                contadorLineas++;
                                acumuladorPromedio += (real / plan * 100);
                                acumuladorPlan += plan;
                                acumuladorReal += real;
                            }

                            }
                            catch (Exception ex1)
                            {
                                Response.Write("Error ex1: " + ex1.Message + "<br>" + queryPlan + "<br>" + queryReal + "<br>");
                                continue;
                            }
                           
                        }

                        string planText = encendidaA == 1 && plan > 0 ? plan.ToString() : "0";
                        string realText = encendidaA == 1 && real > 0 ? real.ToString() : "0";
                        string diferenciaText = encendidaA == 1 && diferencia != 0 ? diferencia.ToString() : "0";

                        worksheet.Cell(row, 1).Value = aliasLinea.ToUpper();
                        worksheet.Cell(row, 2).Value = planText;
                        worksheet.Cell(row, 3).Value = realText;
                        worksheet.Cell(row, 4).Value = diferenciaText;
                        worksheet.Cell(row, 5).Value = estado.ToUpper();
                        worksheet.Cell(row, 6).Value = MFG101Construct;

                        tablaHTML += "<tr " + colorHTML + ">";
                        tablaHTML += "<td>" + aliasLinea.ToUpper() + "</td>";
                        tablaHTML += "<td>" + planText + "</td>";
                        tablaHTML += "<td>" + realText + "</td>";
                        tablaHTML += "<td>" + diferenciaText + "</td>";
                        tablaHTML += "<td>" + estado.ToUpper() + "</td>";
                        tablaHTML += "<td>" + MFG101Construct + "</td>";
                        tablaHTML += "</tr>";

                        row++;

                        // Crear diccionario para un registro
                        Dictionary<string, object> registro = new Dictionary<string, object>()
                        {
                            { "idPlanta", idPlanta },
                            { "Planta", nombrePlanta }, 
                            { "Fecha", FechaRecibida },
                            { "Turno", Turno },
                            { "Zona", Convert.ToInt32(Zona) },
                            { "PrimeraUltima", Titulo.Contains("Primera") ? 0 : 1 },
                            { "Linea", nombreLinea },
                            { "Programado", plan },
                            { "Producido", real },
                            { "Diferencia", diferencia },
                            { "Cumplimiento", plan > 0 ? (real / plan * 100) : 0}
                        };

                        registrosPlanta.Add(registro);
                    }

                    tablaHTML += "</table>";
                    worksheet.Columns().AdjustToContents();

                    using (MemoryStream stream = new MemoryStream())
                    {
                        workbook.SaveAs(stream);
                        stream.Position = 0;

                        if (plantaEmails.ContainsKey(idPlanta))
                        {
                            // Enviar correo solo si hay destinatarios para esta planta
                            EnviarCorreo(nombrePlanta, tablaHTML, stream, (acumuladorPromedio / contadorLineas).ToString("0.00"), plantaEmails[idPlanta], (acumuladorReal / acumuladorPlan * 100).ToString("0.00"));

                            // Añadir los destinatarios a la lista para el reporte final
                            reportesEnviados[nombrePlanta] = plantaEmails[idPlanta];
                        }
                    }                  
                }
                 // Añadir los registros de la planta al diccionario principal
                datosPorPlanta[idPlanta] = registrosPlanta;
                // Llamada a la función para insertar los datos en bulk
                if (registrosPlanta.Count > 0)
                {
                   if (TestTrigger == 0){ InsertarDatosEnBulk(datosPorPlanta[idPlanta]); }
                }             
                             
                
            }           
            

            // Enviar correo de confirmación con la lista de destinatarios por planta
            EnviarCorreoConfirmacion(reportesEnviados);
            
            Response.Write(FechaQuery + " Fecha<\br>");
            Response.Write("Correos enviados correctamente. <br>");
            
        /*}
        catch (Exception ex)
        {
            // Imprimir el error en la respuesta HTTP
            Response.Write("Error: " + ex.Message);            
        }*/

    }
    else
    {
        Response.Write("Método no permitido.");
    }
}

// Método para ejecutar consultas SQL
private DataTable EjecutarQuery(string connectionString, string query)
{
    DataTable dataTable = new DataTable();
    //HttpContext.Current.Response.Write(query + " <br>");
   
    using (SqlConnection connection = new SqlConnection(connectionString))
    {
        SqlCommand command = new SqlCommand(query, connection);
        command.CommandTimeout = 60;
        connection.Open();
        SqlDataAdapter adapter = new SqlDataAdapter(command);
        adapter.Fill(dataTable);
    }
    return dataTable;
}

// Método para obtener los correos electrónicos por planta
private Dictionary<int, List<string>> GetEmailsByPlant(string connectionString, string query)
{
    Dictionary<int, List<string>> emailsByPlant = new Dictionary<int, List<string>>();
    using (SqlConnection connection = new SqlConnection(connectionString))
    {
        SqlCommand command = new SqlCommand(query, connection);
        connection.Open();
        SqlDataReader reader = command.ExecuteReader();
        while (reader.Read())
        {
            int planta = Convert.ToInt32(reader["idPlanta"]);
            string email = reader["Email"].ToString();
            if (!emailsByPlant.ContainsKey(planta))
            {
                emailsByPlant[planta] = new List<string>();
            }
            emailsByPlant[planta].Add(email);
        }
    }
    return emailsByPlant;
}

// Método para enviar el correo
private void EnviarCorreo(string planta, string tablaHTML, MemoryStream adjunto, string cumplimiento, List<string> correos, string cumplimientoGeneral)
{
    string smtpServer = "smtp.aptiv.com";
    string fechaActual = Request["Fecha"] != null ?  Request["Fecha"].ToString() : DateTime.Now.ToString("MM-dd-yyyy");
    string Titulo = Request["Titulo"].ToString();
    string Turno = Request["Turno"].ToString();
    int smtpPort = 25;
    var smtpClient = new SmtpClient(smtpServer, smtpPort);

    // Determinar la clasificación del cumplimiento
    string clasificacion;
    double cumplimientoPorcentaje = Convert.ToDouble(cumplimiento);
    if (cumplimientoPorcentaje >= 100)
    {
        clasificacion = "Sobresaliente";
    }
    else if (cumplimientoPorcentaje >= 90 && cumplimientoPorcentaje < 100)
    {
        clasificacion = "Bueno";
    }
    else if (cumplimientoPorcentaje >= 50 && cumplimientoPorcentaje < 90)
    {
        clasificacion = "Malo";
    }
    else if (cumplimientoPorcentaje >= 0 && cumplimientoPorcentaje < 50)
    {
        clasificacion = "Grave";
    }
    else 
    {
        clasificacion = "Sin Linieas Activas";
    }

    var mailMessage = new MailMessage
    {
        From = new MailAddress("OpExITInnovation@aptiv.com", "MCI Reports"),
        Subject = "REPORTE DE " + Titulo + " TURNO " + Turno + " - Planta " + planta.ToUpper(),
        Body = @"
            <html>
            <head>
                <style>
                    body { font-family: Arial, sans-serif; background-color: #f4f4f4; }
                    .header { background-color: #004080; color: white; padding: 10px; text-align: center; font-size: 18px; }
                    table { width: 100%; border-collapse: collapse; }
                    th, td { padding: 10px; text-align: center; border: 1px solid #ddd; }
                    th { background-color: #f2f2f2; }
                    tr:nth-child(even) { background-color: #f9f9f9; }
                    .cumplimiento { font-weight: bold; color: #004080; }
                    .clasificacion { font-weight: bold; color: #D32F2F; }
                </style>
            </head>
            <body>
                <div class='header'>Reporte de Producci&oacute;n " + Titulo + @" Turno " + Turno + @" - Planta " + planta.ToUpper() + @"</div>
                <p>Estimado equipo,</p>
                <p>Adjunto encontrar&aacute;s el reporte de producci&oacute;n correspondiente a la fecha " + fechaActual + @". A continuaci&oacute;n se presenta un resumen:</p>
                <p>Porcentaje De Cumplimiento Total Planta: <span class='cumplimiento'>" + cumplimientoGeneral + @"%</span>. <span class='clasificacion'>" + clasificacion + @"</span></p>
                <p>Porcentaje De Cumplimiento Promedio Por Linea: <span class='cumplimiento'>" + cumplimientoPorcentaje + @"%</span>. <span class='clasificacion'>" + clasificacion + @"</span></p>
                " + tablaHTML + @"
                <p>Saludos cordiales,<br>Equipo de OpEx IT</p>
                <div style='margin-top: 20px; text-align: center; font-size: 12px; color: #888;'>© 2024 Aptiv. Todos los derechos reservados.</div>
            </body>
            </html>",
        IsBodyHtml = true
    };

    foreach (string email in correos)
    {
        mailMessage.To.Add(email);
    }
    mailMessage.Attachments.Add(new Attachment(adjunto, "Reporte_Produccion_" + planta + ".xlsx"));

    smtpClient.Send(mailMessage);
}

// Método para enviar el correo de confirmación final
private void EnviarCorreoConfirmacion(Dictionary<string, List<string>> reportesEnviados)
{
    string smtpServer = "smtp.aptiv.com";
    int smtpPort = 25;
    string Titulo = Request["Titulo"].ToString();
    string Turno = Request["Turno"].ToString();
    string Zona = Request["Zona"].ToString();
    string Fecha = Request["Fecha"] != null ?  Request["Fecha"].ToString() : DateTime.Now.ToString("MMM-dd-yyyy");
    var smtpClient = new SmtpClient(smtpServer, smtpPort);

    // Crear el cuerpo del correo
    string body = "<html><body>";
    body += "<h2>Confirmaci&oacute;n de Env&iacute;o de Reportes de " + Titulo + " Zona " + Zona + " Turno " + Turno + "</h2>";
    body += "<p>Se han enviado los reportes a las siguientes plantas y destinatarios:</p>";
    body += "<ul>";

    foreach (var planta in reportesEnviados)
    {
        body += "<li><strong>Planta: " + planta.Key + "</strong><ul>";
        foreach (var email in planta.Value)
        {
            body += "<li>" + email + "</li>";
        }
        body += "</ul></li>";
    }

    body += "</ul>";
    body += "<p>Saludos,<br>Equipo de OpEx IT</p>";
    body += "</body></html>";

    // Configurar el mensaje
    var mailMessage = new MailMessage
    {
        From = new MailAddress("OpExITInnovation@aptiv.com", "MCI Reports"),
        Subject = "Confirmación de Envío de Reportes - " + Fecha,
        Body = body,
        IsBodyHtml = true
    };

    // Añadir el correo de confirmación
    mailMessage.To.Add("jose.angel.cordoba@aptiv.com");
    mailMessage.To.Add("alejandro.a.nava@aptiv.com");

    // Enviar el correo
    smtpClient.Send(mailMessage);
}

public static void InsertarDatosEnBulk(List<Dictionary<string, object>> datosPorPlanta)
{
    string connectionString = "Server=USVIASH-DB06;Database=DTv2;User Id=apps;Password=99552499*;";
    string sPlanta = "";
    StringBuilder bulkInsertQuery = new StringBuilder();
    using (SqlConnection connection = new SqlConnection(connectionString))
    {
       try
       {
        connection.Open();
        
        // Construir el string de SQL para el bulk insert
        
        bulkInsertQuery.Append("INSERT INTO [Reportes_FH_LH] (idPlanta, Planta, Fecha, Turno, Zona, PrimeraUltima, Linea, Programado, Producido, Diferencia, Cumplimiento, fh) VALUES ");

       
            foreach (var registro in datosPorPlanta)
            {
                // Construir cada línea de valores para insertar
                string values = string.Format(
                    "({0}, '{1}', '{2}', '{3}', {4}, {5}, '{6}', {7}, {8}, {9}, {10}, '{11}')",
                    Convert.ToInt32(registro["idPlanta"]),
                    registro["Planta"].ToString().Replace("'", "''"), // Escapar apóstrofes
                    Convert.ToDateTime(registro["Fecha"]).ToString("yyyy-MM-dd HH:mm:ss"), // Fecha formateada
                    registro["Turno"].ToString().Replace("'", "''"),
                    Convert.ToInt32(registro["Zona"]),
                    Convert.ToInt32(registro["PrimeraUltima"]),
                    registro["Linea"].ToString().Replace("'", "''"),
                    Convert.ToDouble(registro["Programado"]),
                    Convert.ToDouble(registro["Producido"]),
                    Convert.ToDouble(registro["Diferencia"]),
                    Convert.ToDouble(registro["Cumplimiento"]),
                    DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss")
                );
                sPlanta = registro["Planta"].ToString().Replace("'", "''");
                //HttpContext.Current.Response.Write(values + " <br>");

                // Agregar los valores al query
                bulkInsertQuery.Append(values + ",");
            }
        

        // Remover la última coma
        bulkInsertQuery.Length--; 

        // Ejecutar el query
        using (SqlCommand cmd = new SqlCommand(bulkInsertQuery.ToString(), connection))
        {
            cmd.ExecuteNonQuery();
        }

        

       }
       catch (Exception ex)
       {
        //HttpContext.Current.Response.Write("Error: " + ex.Message + "<br>");
        // Configuración inicial para el envío de correo de error
        string Zona = HttpContext.Current.Request["Zona"].ToString();
            string Turno = HttpContext.Current.Request["Turno"].ToString();
            string Hora = HttpContext.Current.Request["Hora"].ToString();
            string Titulo = HttpContext.Current.Request["Titulo"].ToString();
            string smtpServer = "smtp.aptiv.com";
            int smtpPort = 25;
            var smtpClient = new SmtpClient(smtpServer, smtpPort);

            var mailMessage = new MailMessage
            {
                From = new MailAddress("OpExITInnovation@aptiv.com", "MCI Reports"),
                Subject = "ERROR: Problema en la ejecuci&oacute;n de ReportePrimeraHoraZona0.aspx",
                Body = @"
                    <html>
                    <head>
                        <style>
                            body { font-family: Arial, sans-serif; background-color: #f4f4f4; }
                            .header { background-color: #004080; color: white; padding: 10px; text-align: center; font-size: 18px; }
                        </style>
                    </head>
                    <body>
                        <div class='header'>Error en la Generaci&oacute;n de Reportes</div>
                        <p>Se ha encontrado un problema durante la generaci&oacute;n de reportes:</p>
                        <p>Error: " + ex.Message + @"</p>
                        <p>Zona: " + Zona + @" Turno: " + Turno + @" Hora: " + Hora + @" T&iacute;tulo: " + Titulo + @"</p>
                        <p>Error Al insertar Registros en Planta: " + sPlanta + @"</p>
                        <p>Por favor, revise el sistema y corrija el problema.</p>
                        <p>Query: " + bulkInsertQuery.ToString() + @"</p>
                        <div style='margin-top: 20px; text-align: center; font-size: 12px; color: #888;'>© 2024 Aptiv. Todos los derechos reservados.</div>
                    </body>
                    </html>",
                IsBodyHtml = true
            };

            // Añadir el correo del destinatario que recibirá las notificaciones de error
            mailMessage.To.Add("jose.angel.cordoba@aptiv.com");            
            //mailMessage.To.Add("alejandro.a.nava@aptiv.com");

            try
            {
                smtpClient.Send(mailMessage);
            }
            catch (Exception smtpEx)
            {
                // En caso de que el envío de correo falle, se imprime un error adicional en la respuesta HTTP
                HttpContext.Current.Response.Write("Error al enviar correo de notificación de error: " + smtpEx.Message);
            }

       }
       finally
       {
        connection.Close();
       }
        
    }

}
</script>
