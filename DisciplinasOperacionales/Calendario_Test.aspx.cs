using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Net.Mime;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Globalization;

public partial class Calendario_Test : System.Web.UI.Page
{
    public ConSQL sql;
    public DataTable dtEventos, correosStaff;
    public string eventos = "", hora = "", horaF, mensajeHTML;
    public DateTime fh, start, finish;
    public int hayAgenda, tz;
    List<string> listaStringLR = new List<string>();
    protected void Page_Load(object sender, EventArgs e)
    {
        Credenciales();

        sql = new ConSQL(Env.getAppServerDbConnectionString("DisciplinasOperacionales"));

        if (!IsPostBack)
        {
            sql.llenaDropDownList(ddlArea, sql.selec("SELECT area FROM [DisciplinasOperacionales].[dbo].[Areas] WHERE planta = '" + lblPlanta.Text + "' AND activo = 'True' ORDER BY area"), "area", "area");
            EventosProgramados();
        }
        else
        {
            litMensaje.Text = "";
            EventosProgramados();
        }
    }

    public void Credenciales()
    {
        try{
            lblUsuario.Text = Session["NetId"].ToString();
            lblNombre.Text  = Session["Nombre"].ToString();
            lblPlanta.Text  = Session["Planta"].ToString();
        }catch(Exception ex){
      Response.Redirect(Env.redirectUrl);
        }
    }

    public void EventosProgramados()
    {
        dtEventos = sql.selec("SELECT id, area, CONVERT(VARCHAR(10), fh_agenda, 120) fh_agenda, planta, A.usuario agendo, B.usuario [realizo], evaluacion, CASE WHEN semana < DATEPART(WEEK,GETDATE()) AND A.llave IS NULL THEN 'Vencido' ELSE [status] END [status], A.llave, B.fh fecha_realizo, DATEPART(YEAR, B.fh) year_realizo, DATEPART(MONTH, B.fh) mes_realizo FROM [DisciplinasOperacionales].[dbo].[Agenda_Test] A "
                            + "LEFT JOIN "
                            + "(SELECT usuario, evaluacion, fh, llave FROM [DisciplinasOperacionales].[dbo].[Historial] WHERE planta = '" + lblPlanta.Text + "' AND actualizacion = 'False') B "
                            + "ON A.llave = B.llave WHERE A.planta = '" + lblPlanta.Text + "'");

        if (dtEventos.Rows.Count > 0)
        {
            foreach (DataRow r in dtEventos.Rows)
            {
                if (r["status"].ToString() == "Realizado")
                {
                    fh = DateTime.Parse(r["fecha_realizo"].ToString());

                    if (r["realizo"].ToString() == lblNombre.Text)
                    {
                        eventos += "{ title: ' Area: " + r["area"].ToString() + "', start: '" + r["fh_agenda"].ToString() + "', color: '#2eb82e', textColor: 'white', icon: 'check', url: 'Historial.aspx?us=" + lblUsuario.Text + "&nombre=" + lblNombre.Text + "&p=" + lblPlanta.Text + "&area=" + r["area"].ToString().Replace("&", "%26") + "&year=" + r["year_realizo"].ToString() + "&mes=" + r["mes_realizo"].ToString() + "&fecha=" + fh.ToString("yyyy-MM-dd") + "', description: 'Planta: <b>" + r["planta"].ToString() + "</b><br>Realizo: <b>" + r["realizo"].ToString() + "</b><br>Evaluación: <b><span class=\"" + ObtenerColorEvaluacion(Convert.ToSingle(r["evaluacion"].ToString())) + "\">" + r["evaluacion"].ToString() + "%<span></b><br>Status: <b><span class=\"text-success\">Realizada</span></b><br><div onclick=\"EliminarAgenda(" + r["id"].ToString() + ");\"><img width=\"15\" height=\"15\" src=\"img/basura.png\"/>&nbsp;Eliminar fecha agendada</div>'},";
                    }
                    else
                    {
                        eventos += "{ title: ' Area: " + r["area"].ToString() + "', start: '" + r["fh_agenda"].ToString() + "', color: '#2eb82e', textColor: 'white', icon: 'check', url: 'Historial.aspx?us=" + lblUsuario.Text + "&nombre=" + lblNombre.Text + "&p=" + lblPlanta.Text + "&area=" + r["area"].ToString().Replace("&", "%26") + "&year=" + r["year_realizo"].ToString() + "&mes=" + r["mes_realizo"].ToString() + "&fecha=" + fh.ToString("yyyy-MM-dd") + "', description: 'Planta: <b>" + r["planta"].ToString() + "</b><br>Realizo: <b>" + r["realizo"].ToString() + "</b><br>Evaluación: <b><span class=\"" + ObtenerColorEvaluacion(Convert.ToSingle(r["evaluacion"].ToString())) + "\">" + r["evaluacion"].ToString() + "%<span></b><br>Status: <b><span class=\"text-success\">Realizada</span></b>'},";
                    }
                }
                if (r["status"].ToString() == "Pendiente")
                {
                    eventos += "{ title: ' Area: " + r["area"].ToString() + "', start: '" + r["fh_agenda"].ToString() + "', color: '#ffcc00', textColor: 'black', icon: 'clock-o', url: 'Checklist.aspx?us=" + lblUsuario.Text + "&nombre=" + lblNombre.Text + "&p=" + lblPlanta.Text + "&area=" + r["area"].ToString().Replace("&", "%26") + "', description: 'Planta: <b>" + r["planta"].ToString() + "</b><br>Agendo: <b>" + r["agendo"].ToString() + "</b><br>Status: <b><span class=\"text-orange\">Pendiente</span></b><br><div onclick=\"EliminarAgenda(" + r["id"].ToString() + ");\"><img width=\"15\" height=\"15\" src=\"img/basura.png\"/>&nbsp;Eliminar fecha agendada</div>'},";
                }
                if (r["status"].ToString() == "Vencido")
                {
                    eventos += "{ title: ' Area: " + r["area"].ToString() + "', start: '" + r["fh_agenda"].ToString() + "', color: '#e62e00', textColor: 'white', icon: 'times', description: 'Planta: <b>" + r["planta"].ToString() + "</b><br>Agendo: <b>" + r["agendo"].ToString() + "</b><br>Status: <b><span class=\"text-danger\">Vencido</span></b><br><div onclick=\"EliminarAgenda(" + r["id"].ToString() + ");\"><img width=\"15\" height=\"15\" src=\"img/basura.png\"/>&nbsp;Eliminar fecha agendada</div>'},";
                }
            }

            eventos = eventos.Remove(eventos.Length - 1, 1);
        }
    }

    protected void btnAgendar_Click(object sender, EventArgs e)
    {
        correosStaff = sql.selec("SELECT correo FROM [DisciplinasOperacionales].[dbo].[Staff_Test] WHERE planta = '" + lblPlanta.Text + "'");
        if (ddlArea.Items.Count > 0)
        {
            hayAgenda = Convert.ToInt32(sql.scalar("SELECT COUNT(*) cant FROM [DisciplinasOperacionales].[dbo].[Agenda_Test] WHERE planta = '" + lblPlanta.Text + "' AND area = '" + ddlArea.SelectedItem.Text + "' AND fh_agenda = '" + Request.Form["txtFh"] + "'"));

            if (hayAgenda == 0)
            {
                sql.exec("INSERT INTO [DisciplinasOperacionales].[dbo].[Agenda_Test] (area, fh_agenda, hora, semana, planta, usuario, status) VALUES ('" + ddlArea.SelectedItem.Text + "', '" + Request.Form["txtFh"] + "', '" + Request.Form["txtHora"] + "', DATEPART(WEEK, '" + Request.Form["txtFh"] + "'), '" + lblPlanta.Text + "', '" + lblNombre.Text + "', 'Pendiente')");
                
                tz = Convert.ToInt32(sql.scalar("SELECT zona_horaria FROM [CatPlantas].[dbo].[Cat_Plantas] WHERE planta = '" + lblPlanta.Text + "'"));
                start = DateTime.Parse(Request.Form["txtFh"] + " " + Request.Form["txtHora"]).AddHours(-tz);
                
                WebRequest MandarCorreo = WebRequest.Create("http://10.223.36.253/EnvioCorreoWS/Correo.asmx/CrearCorreo?app=DO&tipoCorreo=MR&usuario=" + lblNombre.Text + "&fh=" + Request.Form["txtFh"] + " " + Request.Form["txtHora"] + "&planta=" + lblPlanta.Text + "&area=" + ddlArea.SelectedItem.Text + "&mensaje=" + Request.Form["txtMensaje"] + "&queryCorreos=SELECT DISTINCT correo FROM [DisciplinasOperacionales].[dbo].[Staff_Test] WHERE planta = '" + lblPlanta.Text + "'");
                MandarCorreo.Method = "GET";
                WebResponse respuesta = MandarCorreo.GetResponse();

                litMensaje.Text = "<script>swal({title: '', text: 'Se ha agendado la evaluación correctamente.',type: 'success', confirmButtonClass: 'btn-success', confirmButtonText: 'OK', closeOnConfirm: false},function(){  window.location.href = 'Calendario_Test.aspx?&us=" + lblUsuario.Text + "&nombre=" + lblNombre.Text + "&p=" + lblPlanta.Text + "'; });</script>";
            }
            else
            {
                litMensaje.Text = "<script>swal('','Ya existe una evaluación agendada para esta fecha. Intenta con una fecha diferente.','warning');</script>";
            }
        }
    }

    protected void btnEliminar_Click(object sender, EventArgs e)
    {
        dtEventos = sql.selec("SELECT id, area, CONVERT(VARCHAR(10), fh_agenda, 120) fh_agenda, planta, usuario, status FROM [DisciplinasOperacionales].[dbo].[Agenda_Test] WHERE planta = '" + lblPlanta.Text + "' AND id = " + Request["txtAgenda"]);

        if (dtEventos.Rows.Count > 0)
        {
            foreach (DataRow r in dtEventos.Rows)
            {
                if (Request["txtAgenda"] != null)
                {
                    sql.exec("DELETE FROM [DisciplinasOperacionales].[dbo].[Agenda_Test] WHERE id = " + Request["txtAgenda"]);
                }
            }

            litMensaje.Text = "<script>swal({title: '', text: 'La fecha agendada se ha eliminado correctamente.',type: 'success', confirmButtonClass: 'btn-success', confirmButtonText: 'OK', closeOnConfirm: false},function(){  window.location.href = 'Calendario_Test.aspx?&us=" + lblUsuario.Text + "&nombre=" + lblNombre.Text + "&p=" + lblPlanta.Text + "'; });</script>";
        }
    }

    public string ObtenerColorEvaluacion(float total)
    {
        string color = "";

        if (total < 95)
        {
            color = "text-danger";
        }
        if (total >= 95 && total < 98)
        {
            color = "text-warning";
        }
        if (total >= 98)
        {
            color = "text-success";
        }

        return color;
    }

    void enviar_correos(DateTime start, DateTime end, string query_correo)
    {
        try
        {
            string meetingSubject = "Disciplinas Operacionales Meeting Request";
            string meetingOrganizerName = "Aptiv Manufactura";
            string cuerpoCorreo = "";
            string meetingOrganizerMail = "manufactura@aptiv.com";
            string meetingSummary = "", meetingLocation = lblPlanta.Text;
            string mensaje = Request.Form["txtMensaje"], agendador = lblNombre.Text, 
                area = ddlArea.SelectedItem.Text, planta = lblPlanta.Text;
            DataTable dt_Usuarios;

            dt_Usuarios = sql.selec(query_correo);
            if (dt_Usuarios.Rows.Count > 0)
            {
                MailAddressCollection correos = new MailAddressCollection();
                foreach (DataRow fila in dt_Usuarios.Rows)
                {
                    correos.Add(fila["correo"].ToString());
                }
                cuerpoCorreo = crear_html(cuerpoCorreo, start, end, planta, agendador, area, mensaje);
                enviar_meeting(start, end, cuerpoCorreo, meetingSubject, meetingSummary, meetingLocation, meetingOrganizerName, meetingOrganizerMail, correos);

                correos.Clear();//Limpiar lista de Correos para envío.
                cuerpoCorreo = "";
            }
        }
        catch (Exception ex)
        {
            //MessageBox.Show("Error: \r" + ex);
        }
    }
    public string crear_html(string cuerpoCorreo, DateTime start, DateTime end, string planta, string agendador, string area, string mensaje)
    {
        cuerpoCorreo = cuerpoCorreo + "<html>";
        cuerpoCorreo = cuerpoCorreo + "<head>";
        cuerpoCorreo = cuerpoCorreo + "<meta charset='utf-8'>";
        cuerpoCorreo = cuerpoCorreo + "<style>";
        cuerpoCorreo = cuerpoCorreo + "body {font-family: Sans-serif}";
        cuerpoCorreo = cuerpoCorreo + "</style>";
        cuerpoCorreo = cuerpoCorreo + "</head>";
        cuerpoCorreo = cuerpoCorreo + "<body>";
        cuerpoCorreo = cuerpoCorreo + "<table align='center' width='100%' style='border-collapse:collapse; border:1px solid black; text-align:left;'>";
        cuerpoCorreo = cuerpoCorreo + "<thead>";
        cuerpoCorreo = cuerpoCorreo + "<tr><th colspan='4' style='font-weight:bold; font-size:20px; background-color:#FF7300; color:white;'>Evaluaci&oacute;n de Disciplinas Operacionales para " + planta + "</th></tr>";
        cuerpoCorreo = cuerpoCorreo + "</thead>";
        cuerpoCorreo = cuerpoCorreo + "<tbody>";
        cuerpoCorreo = cuerpoCorreo + "<tr>";
        cuerpoCorreo = cuerpoCorreo + "<td style='background-color:#B8A291;color:white;font-size:16px;text-align:center;border:1px solid black;'>";
        cuerpoCorreo = cuerpoCorreo + "Fecha";
        cuerpoCorreo = cuerpoCorreo + "</td>";
        cuerpoCorreo = cuerpoCorreo + "<td style='background-color:#B8A291;color:white;font-size:16px;text-align:center;border:1px solid black;'>";
        cuerpoCorreo = cuerpoCorreo + "&Aacute;rea";
        cuerpoCorreo = cuerpoCorreo + "</td>";
        cuerpoCorreo = cuerpoCorreo + "<td style='background-color:#B8A291;color:white;font-size:16px;text-align:center;border:1px solid black;'>";
        cuerpoCorreo = cuerpoCorreo + "Agendada por";
        cuerpoCorreo = cuerpoCorreo + "</td>";
        cuerpoCorreo = cuerpoCorreo + "<td style='background-color:#B8A291;color:white;font-size:16px;text-align:center;border:1px solid black;'>";
        cuerpoCorreo = cuerpoCorreo + "Mensaje";
        cuerpoCorreo = cuerpoCorreo + "</td>";
        cuerpoCorreo = cuerpoCorreo + "</tr>";

        cuerpoCorreo = cuerpoCorreo + "<tr>";
        cuerpoCorreo = cuerpoCorreo + "<td style='font-size:14px;text-align:center;border:1px solid black;'>";
        cuerpoCorreo = cuerpoCorreo + start.ToString("f", CultureInfo.CreateSpecificCulture("es-ES"));
        cuerpoCorreo = cuerpoCorreo + "</td>";
        cuerpoCorreo = cuerpoCorreo + "<td style='font-size:14px;text-align:center;border:1px solid black;'>";
        cuerpoCorreo = cuerpoCorreo + area;
        cuerpoCorreo = cuerpoCorreo + "</td>";
        cuerpoCorreo = cuerpoCorreo + "<td style='font-size:14px;text-align:center;border:1px solid black;'>";
        cuerpoCorreo = cuerpoCorreo + agendador;
        cuerpoCorreo = cuerpoCorreo + "</td>";
        cuerpoCorreo = cuerpoCorreo + "<td style='font-size:14px;border:1px solid black;'>";
        cuerpoCorreo = cuerpoCorreo + mensaje;
        cuerpoCorreo = cuerpoCorreo + "</td>";
        cuerpoCorreo = cuerpoCorreo + "</tr>";

        cuerpoCorreo = cuerpoCorreo + "</tbody>";
        cuerpoCorreo = cuerpoCorreo + "</table>";
        cuerpoCorreo = cuerpoCorreo + "<center><img src='http://10.223.36.253/DisciplinasOperacionales/img/Aptiv_logo.png' width='300'/></center>";
        cuerpoCorreo = cuerpoCorreo + "</body>";
        cuerpoCorreo = cuerpoCorreo + "</html>";

        return cuerpoCorreo;
    }
    public void enviar_meeting(DateTime start, DateTime end, string bodyHTML, string subject, string summary, string location, string organizerName, string organizerEmail, MailAddressCollection attendeeList)
    {
            MailMessage mail = new MailMessage();
            mail.Priority = MailPriority.High;
            System.Net.Mime.ContentType textType = new System.Net.Mime.ContentType("text/plain");
            System.Net.Mime.ContentType HTMLType = new System.Net.Mime.ContentType("text/html");
            System.Net.Mime.ContentType calendarType = new System.Net.Mime.ContentType("text/calendar");
            //Add parameters to the calendar header
            calendarType.Parameters.Add("method", "REQUEST");
            calendarType.Parameters.Add("name", "meeting.ics");

            //Crea el cuerpo en formato de texto
            string bodyText = "Type:Single Meeting\r\nOAgendado por: {0}\r\nComienzo: {1}\r\nFinal: {2}\r\nZona Horaria: {3}\r\nLugar: {4}\r\n\r\n*~*~*~*~*~*~*~*~*~*\r\n\r\n{5}";
            bodyText = string.Format(bodyText, organizerName, start.ToLongDateString() + " " + start.ToLongTimeString(), end.ToLongDateString() + " " + end.ToLongTimeString(), System.TimeZone.CurrentTimeZone.StandardName, location, summary);
            AlternateView textView = AlternateView.CreateAlternateViewFromString(bodyText, textType);
            mail.AlternateViews.Add(textView);

            //Crea el cuerpo en formato de HTML
            AlternateView HTMLView = AlternateView.CreateAlternateViewFromString(bodyHTML, HTMLType);
            mail.AlternateViews.Add(HTMLView);

            //Crear vista de calendario NO cambiar el ORDEN
            string calDateFormat = "yyyyMMddTHHmmssZ"; string bodyCalendar = "BEGIN:VCALENDAR\r\nMETHOD:REQUEST\r\nPRODID:Microsoft CDO for Microsoft Exchange\r\nVERSION:2.0\r\nBEGIN:VTIMEZONE\r\nTZID:(GMT-06.00) Central Time (US & Canada)\r\nX-MICROSOFT-CDO-TZID:11\r\nBEGIN:STANDARD\r\nDTSTART:16010101T020000\r\nTZOFFSETFROM:-0500\r\nTZOFFSETTO:-0600\r\nRRULE:FREQ=YEARLY;WKST=MO;INTERVAL=1;BYMONTH=11;BYDAY=1SU\r\nEND:STANDARD\r\nBEGIN:DAYLIGHT\r\nDTSTART:16010101T020000\r\nTZOFFSETFROM:-0600\r\nTZOFFSETTO:-0500\r\nRRULE:FREQ=YEARLY;WKST=MO;INTERVAL=1;BYMONTH=3;BYDAY=2SU\r\nEND:DAYLIGHT\r\nEND:VTIMEZONE\r\nBEGIN:VEVENT\r\nDTSTAMP:{8}\r\nDTSTART:{0}\r\nSUMMARY:{7}\r\nUID:{5}\r\nATTENDEE;ROLE=REQ-PARTICIPANT;PARTSTAT=NEEDS-ACTION;RSVP=TRUE;CN=\"{9}\":MAILTO:{9}\r\nACTION;RSVP=TRUE;CN=\"{4}\":MAILTO:{4}\r\nORGANIZER;CN=\"{3}\":mailto:{4}\r\nLOCATION:{2}\r\nDTEND:{1}\r\nDESCRIPTION:{7}\\N\r\nSEQUENCE:1\r\nPRIORITY:5\r\nCLASS:\r\nCREATED:{8}\r\nLAST-MODIFIED:{8}\r\nSTATUS:CONFIRMED\r\nTRANSP:OPAQUE\r\nX-MICROSOFT-CDO-BUSYSTATUS:BUSY\r\nX-MICROSOFT-CDO-INSTTYPE:0\r\nX-MICROSOFT-CDO-INTENDEDSTATUS:BUSY\r\nX-MICROSOFT-CDO-ALLDAYEVENT:FALSE\r\nX-MICROSOFT-CDO-IMPORTANCE:1\r\nX-MICROSOFT-CDO-OWNERAPPTID:-1\r\nX-MICROSOFT-CDO-ATTENDEE-CRITICAL-CHANGE:{8}\r\nX-MICROSOFT-CDO-OWNER-CRITICAL-CHANGE:{8}\r\nBEGIN:VALARM\r\nACTION:DISPLAY\r\nDESCRIPTION:REMINDER\r\nTRIGGER;RELATED=START:-PT00H15M00S\r\nEND:VALARM\r\nEND:VEVENT\r\nEND:VCALENDAR\r\n";

            bodyCalendar = string.Format(bodyCalendar, start.ToUniversalTime().ToString(calDateFormat), end.ToUniversalTime().ToString(calDateFormat), location, organizerName, organizerEmail, Guid.NewGuid().ToString("B"), summary, subject, DateTime.Now.ToUniversalTime().ToString(calDateFormat), attendeeList.ToString());
            AlternateView calendarView = AlternateView.CreateAlternateViewFromString(bodyCalendar, calendarType);
            calendarView.TransferEncoding = TransferEncoding.SevenBit;
            mail.AlternateViews.Add(calendarView);

            // Adress the message
            mail.From = new MailAddress(organizerEmail);
            mail.To.Add(attendeeList.ToString());
            mail.Subject = subject;

            SmtpClient client = new SmtpClient("mail.delphi.com", 25);
            client.DeliveryMethod = SmtpDeliveryMethod.Network;
            //client.EnableSsl = true;

            NetworkCredential credentials = new NetworkCredential("erick.i.moxthe@aptiv.com", "PuercO0000");
            client.UseDefaultCredentials = false;
            client.Credentials = credentials;
            client.Send(mail);
        
        
    }
}