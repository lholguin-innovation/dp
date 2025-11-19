using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Newtonsoft.Json; 
using System.Web.Services;
using System.IO.Compression;

public partial class Calendario : System.Web.UI.Page
{
    public ConSQL sql;
    public DataTable dtEventos;
    public string eventos = "";
    public DateTime fh;
    public int hayAgenda;
    public bool debug=true;

    protected void Page_Load(object sender, EventArgs e)
    {
        litDebug.Text="";
        litDebug.Visible=debug;
        Credenciales();

        sql = new ConSQL(Env.getAppServerDbConnectionString("DisciplinasOperacionales"));

        if (!IsPostBack)
        {
            sql.llenaDropDownList(ddlArea, sql.selec("SELECT area FROM [DisciplinasOperacionales].[dbo].[Areas] WHERE planta = '" + lblPlanta.Text + "' AND activo = 'True' ORDER BY area"), "area", "area");
 
        }
        else
        {
            litMensaje.Text = ""; 
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


   [System.Web.Services.WebMethod]
   [System.Web.Script.Services.ScriptMethod(UseHttpGet =false,ResponseFormat =System.Web.Script.Services.ResponseFormat.Json)]
	public static void getAgenda(string planta, string nombre, string usuario, string anio, string mes)
	{   
        int status=1;
        List<string> lstMsgs = new List<string>();
        ConSQL sql = new ConSQL();
        DataTable dtEventos = new DataTable();
        List<object> lstData= new List<object>();
		string sqlEventos="SELECT id, area, CONVERT(VARCHAR(10), fh_agenda, 120) fh_agenda, planta, A.usuario agendo, B.usuario [realizo], CASE WHEN status = 'Realizado' THEN ISNULL(evaluacion,'100') else evaluacion END evaluacion, CASE WHEN DATEPART(YEAR,fh_agenda) <= DATEPART(YEAR,GETDATE()) AND DATEPART(MONTH,fh_agenda) < DATEPART(MONTH,GETDATE()) AND A.llave IS NULL THEN 'Vencido' ELSE [status] END [status], A.llave, ISNULL(B.fh, fh_agenda) fecha_realizo, DATEPART(YEAR, ISNULL(B.fh, fh_agenda)) year_realizo, DATEPART(MONTH, ISNULL(B.fh, fh_agenda)) mes_realizo "
                            + "FROM [DisciplinasOperacionales].[dbo].[Agenda] A "
                            + "LEFT JOIN "
                            + "(SELECT usuario, evaluacion, fh, llave FROM [DisciplinasOperacionales].[dbo].[Historial] WHERE planta = '" + planta + "' AND actualizacion = 'False') B "
                            + "ON A.llave = B.llave WHERE A.planta = '" + planta + "' "
                            + "AND datepart(year, fh_agenda) = '"+anio+"' "
                            + "AND datepart(month, fh_agenda) = '"+mes+"' ORDER BY fh_agenda";
        lstMsgs.Add(sqlEventos);
        try{
            sql = new ConSQL(Env.getAppServerDbConnectionString("DisciplinasOperacionales")); 
            dtEventos = sql.selec(sqlEventos);
            foreach (DataRow r in dtEventos.Rows)
            {
                
                string title=" Area: " + r["area"].ToString();
                string start=r["fh_agenda"].ToString() ;
                string color="#2eb82e";
                string textColor="white";
                string icon="check";
                string url="";
                string description="";
                if (r["status"].ToString() == "Realizado")
                {
                     /*lstMsgs.Add(r["id"].ToString() + " - " + r["fecha_realizo"].ToString());    
                     lstMsgs.Add(r["fecha_realizo"].ToString() != "" ? "True" : "False");    */             
                    DateTime fh = DateTime.Parse(r["fecha_realizo"].ToString());
                    
                    string colorEval = "";
                    float total=Convert.ToSingle(r["evaluacion"].ToString());
                    if (total < 95)
                    {
                        colorEval = "text-danger";
                    }
                    if (total >= 95 && total < 98)
                    {
                        colorEval = "text-warning";
                    }
                    if (total >= 98)
                    {
                        colorEval = "text-success";
                    }

                    url= "Historial.aspx?us=" + usuario + "&nombre=" + nombre + "&p=" + planta + "&area=" + r["area"].ToString().Replace("&", "%26") + "&year=" + r["year_realizo"].ToString() + "&mes=" + r["mes_realizo"].ToString() + "&fecha=" + r["fecha_realizo"].ToString();
                    lstMsgs.Add(r["id"].ToString() + " - OK");
                    if (r["realizo"].ToString() == nombre)
                    {
                        description= "Planta: <b>" + r["planta"].ToString() + "</b><br>Realizó: <b>" + r["realizo"].ToString() + "</b><br>Evaluación: <b><span class=\"" + colorEval + "\">" + r["evaluacion"].ToString() + "%<span></b><br>Status: <b><span class=\"text-success\">Realizada</span></b><br><div onclick=\"EliminarAgenda(" + r["id"].ToString() + ");\"><img width=\"15\" height=\"15\" src=\"img/basura.png\"/>&nbsp;Eliminar fecha agendada</div>";
                    }
                    else
                    {
                        description= "Planta: <b>" + r["planta"].ToString() + "</b><br>Realizó: <b>" + r["realizo"].ToString() + "</b><br>Evaluación: <b><span class=\"" + colorEval + "\">" + r["evaluacion"].ToString() + "%<span></b><br>Status: <b><span class=\"text-success\">Realizada</span></b>";
                    }
                      
                }
                if (r["status"].ToString() == "Pendiente")
                {
                    color="#ffcc00";
                    textColor="black";
                    icon="clock-o";
                    url= "Checklist.aspx?us=" + usuario + "&nombre=" + nombre + "&p=" + planta + "&id=" + r["id"].ToString() + "&area=" + r["area"].ToString().Replace("&", "%26");
                    description="Planta: <b>" + r["planta"].ToString() + "</b><br>Agendó: <b>" + r["agendo"].ToString() + "</b><br>Status: <b><span class=\"text-orange\">Pendientes</span></b><br><div onclick=\"EliminarAgenda(" + r["id"].ToString() + ");\"><img width=\"15\" height=\"15\" src=\"img/basura.png\"/>&nbsp;Eliminar fecha agendada</div>";
                }
                if (r["status"].ToString() == "Vencido")
                {
                    color="#e62e00";
                    icon="times";
                    description="Planta: <b>" + r["planta"].ToString() + "</b><br>Agendó: <b>" + r["agendo"].ToString() + "</b><br>Status: <b><span class=\"text-danger\">Vencido</span></b><br><div onclick=\"EliminarAgenda(" + r["id"].ToString() + ");\"><img width=\"15\" height=\"15\" src=\"img/basura.png\"/>&nbsp;Eliminar fecha agendada</div>";				
                }
                Object item =  new {
                    title,
                    start,
                    color,
                    textColor,
                    icon,
                    url,
                    description
                };
                lstData.Add(item);
            }
        }catch(Exception ex){
            lstMsgs.Add(ex.ToString());            
        }
		Object resp =  new {
            status,
            lstMsgs,
            lstData//,
      //      dtEventos
        };
		HttpContext.Current.Response.Clear();
		HttpContext.Current.Response.AddHeader("Content-Encoding", "gzip");
        HttpContext.Current.Response.Filter = new GZipStream(HttpContext.Current.Response.Filter, CompressionMode.Compress);
        HttpContext.Current.Response.ContentType = "application/json; charset=utf-8";
        HttpContext.Current.Response.Write( JsonConvert.SerializeObject(resp) );
        HttpContext.Current.Response.Flush();
        HttpContext.Current.Response.End();
	} 
    int Debugs = 0;
    public void PrintDebug(string Mensaje)
    {
        Debugs++;
        string debugIndex = "Debug" + Debugs;
        Mensaje = Mensaje.Replace("'", "-");
        ClientScript.RegisterStartupScript(this.GetType(), debugIndex , "console.log('" + Mensaje + "');", true);
    }

    protected void btnAgendar_Click(object sender, EventArgs e)
    {
        if (ddlArea.Items.Count > 0)
        {
			if (Request["txtHora"].ToString() != "")
			{
				hayAgenda = Convert.ToInt32(sql.scalar("SELECT COUNT(*) cant FROM [DisciplinasOperacionales].[dbo].[Agenda] WHERE planta = '" + lblPlanta.Text + "' AND area = '" + ddlArea.SelectedItem.Text + "' AND fh_agenda = '" + Request.Form["txtFh"] + "'"));

				if (hayAgenda == 0)
				{
					sql.exec("INSERT INTO [DisciplinasOperacionales].[dbo].[Agenda] (area, fh_agenda, semana, planta, usuario, status) VALUES ('" + ddlArea.SelectedItem.Text + "', '" + Request.Form["txtFh"] + "', DATEPART(WEEK, '" + Request.Form["txtFh"] + "'), '" + lblPlanta.Text + "', '" + lblNombre.Text + "', 'Pendiente')");
					
					
					if (Convert.ToDateTime(Request["txtFh"].ToString()) >= DateTime.Now)
					{
                        try{
                            WebRequest MandarCorreo = WebRequest.Create("http://10.223.49.7/EnvioCorreoWS/Correo.asmx/CrearCorreo?app=DO&tipoCorreo=MR&usuario=" + lblNombre.Text + "&fh=" + Request.Form["txtFh"] + " " + Request.Form["txtHora"] + "&planta=" + lblPlanta.Text + "&area=" + ddlArea.SelectedItem.Text + "&mensaje=" + Request.Form["txtMensaje"] + "&queryCorreos=SELECT DISTINCT correo FROM [DisciplinasOperacionales].[dbo].[Staff] WHERE planta = '" + lblPlanta.Text + "' AND correo <> ''");
						MandarCorreo.Method = "GET";
						WebResponse respuesta = MandarCorreo.GetResponse();
                        } catch (Exception ex){
                            PrintDebug(ex.Message + " call: " + "http://10.223.49.7/EnvioCorreoWS/Correo.asmx/CrearCorreo?app=DO&tipoCorreo=MR&usuario=" + lblNombre.Text + "&fh=" + Request.Form["txtFh"] + " " + Request.Form["txtHora"] + "&planta=" + lblPlanta.Text + "&area=" + ddlArea.SelectedItem.Text + "&mensaje=" + Request.Form["txtMensaje"] + "&queryCorreos=SELECT DISTINCT correo FROM [DisciplinasOperacionales].[dbo].[Staff] WHERE planta = '" + lblPlanta.Text + "' AND correo <> ''");
                        }
						
					}  
					

					litMensaje.Text = "<script>swal({title: '', text: 'Se ha agendado la evaluación correctamente.',type: 'success', confirmButtonClass: 'btn-success', confirmButtonText: 'OK', closeOnConfirm: false},function(){  window.location.href = 'Calendario.aspx?&us=" + lblUsuario.Text + "&nombre=" + lblNombre.Text + "&p=" + lblPlanta.Text + "'; });</script>";
				}
				else
				{
					litMensaje.Text = "<script>swal('','Ya existe una evaluación agendada para esta fecha. Intenta con una fecha diferente.','warning');</script>";
				}
			}
			else
			{
				litMensaje.Text = "<script>swal('','Falta agregar la hora de inicio especifica para realizar la evaluación.','warning');</script>";
			}            
        }
    }

    protected void btnEliminar_Click(object sender, EventArgs e)
    {
        dtEventos = sql.selec("SELECT id, area, CONVERT(VARCHAR(10), fh_agenda, 120) fh_agenda, planta, usuario, status FROM [DisciplinasOperacionales].[dbo].[Agenda] WHERE planta = '" + lblPlanta.Text + "' AND id = " + Request["txtAgenda"]);

        if (dtEventos.Rows.Count > 0)
        {
            foreach (DataRow r in dtEventos.Rows)
            {
                if (Request["txtAgenda"] != null)
                {
                    sql.exec("DELETE FROM [DisciplinasOperacionales].[dbo].[Agenda] WHERE id = " + Request["txtAgenda"]);
                }
            }

            litMensaje.Text = "<script>swal({title: '', text: 'La fecha agendada se ha eliminado correctamente.',type: 'success', confirmButtonClass: 'btn-success', confirmButtonText: 'OK', closeOnConfirm: false},function(){  window.location.href = 'Calendario.aspx?&us=" + lblUsuario.Text + "&nombre=" + lblNombre.Text + "&p=" + lblPlanta.Text + "'; });</script>";
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
}