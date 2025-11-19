using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

public partial class Areas : System.Web.UI.Page
{
    public ConSQL sql;
    public DataTable dtAreas, dtAsignacion;
    public DataRow[] rows;
    public string tablaAreas = "", tablaAsignacion = "", nombre = "", correo = "", activo = "";
    public int hayArea, hayAsignacion;

    protected void Page_Load(object sender, EventArgs e)
    {
        Credenciales();

        sql = new ConSQL(Env.getAppServerDbConnectionString("DisciplinasOperacionales"));

        if (!IsPostBack)
        {
            MostrarAreasCargadas();
        }
        else
        {
            litMensaje.Text = "";
            MostrarAreasCargadas();
        }
		litDebug.Visible=false;
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

    protected void btnAgregar_Click(object sender, EventArgs e)
    {
        if (txtArea.Text != "")
        {
            hayArea = Convert.ToInt32(sql.scalar("SELECT COUNT(*) cant FROM [DisciplinasOperacionales].[dbo].[Areas] WHERE area = '" + txtArea.Text + "' AND planta = '" + lblPlanta.Text + "'"));

            if (hayArea == 0)
            {
                sql.exec("INSERT INTO [DisciplinasOperacionales].[dbo].[Areas] (area, planta, usuario, activo) VALUES ('" + txtArea.Text + "','" + lblPlanta.Text + "','" + lblNombre.Text + "','True')");

                txtArea.Text = "";
                litMensaje.Text = "<script>swal({title: '', text: 'Se ha guardado el área correctamente.',type: 'success', confirmButtonClass: 'btn-success', confirmButtonText: 'OK', closeOnConfirm: false},function(){  window.location.href = 'Areas.aspx?&us=" + lblUsuario.Text + "&nombre=" + lblNombre.Text + "&p=" + lblPlanta.Text + "'; });</script>";
            }
            else
            {
                activo = sql.scalar("SELECT CASE WHEN activo = 'True' THEN 1 ELSE 0 END FROM [DisciplinasOperacionales].[dbo].[Areas] WHERE area = '" + txtArea.Text + "' AND planta = '" + lblPlanta.Text + "'").ToString();

                //Si existe pero esta desactivada, la vuelve activar
                if (activo == "0")
                {
                    sql.exec("UPDATE [DisciplinasOperacionales].[dbo].[Areas] SET activo = 'True' WHERE area = '" + txtArea.Text + "' AND planta = '" + lblPlanta.Text + "'");

                    txtArea.Text = "";
                    litMensaje.Text = "<script>swal({title: '', text: 'Se ha guardado el área correctamente.',type: 'success', confirmButtonClass: 'btn-success', confirmButtonText: 'OK', closeOnConfirm: false},function(){  window.location.href = 'Areas.aspx?&us=" + lblUsuario.Text + "&nombre=" + lblNombre.Text + "&p=" + lblPlanta.Text + "'; });</script>";
                }
                else
                {
                    litMensaje.Text = "<script>swal('','Ya existe esta área, intenta con una diferente.','warning');</script>";
                }
            }
        }
        else
        {
            litMensaje.Text = "<script>swal('','Agrega una área para evaluar.','warning');</script>";
        }
    }

    public void MostrarAreasCargadas()
    {
        dtAreas = sql.selec("SELECT * FROM [DisciplinasOperacionales].[dbo].[Areas] WHERE planta = '" + lblPlanta.Text + "' AND activo = 'True' ORDER BY area");
	tablaAreas ="";
        if (dtAreas.Rows.Count > 0)
        {
            tablaAreas += "<table id='tablaAreas' class='table' width='100%'>"
                            + "<thead>"
                                + "<tr class='tr-tipoOSA text-center' style='font-size: 13px;'>"
									+ "<th class='col-4'>Departamento</th>"
                                    + "<th class='col-6'>&Aacute;reas capturadas</th>"
                                    + "<th class='col-2'></th>"
                                + "</tr>"
                            + "</thead>"
                            + "<tbody>";

			DataTable dtDeptos = sql.selec("SELECT distinct Departamento Departamento "
									+"FROM [DisciplinasOperacionales].[dbo].[Disciplinas]"
									+"where NOT Departamento is null");
			int cont=0;
            foreach (DataRow r in dtAreas.Rows)
            { 
				string opcionesDptos="";
				string strSel="";
				 
				opcionesDptos="<option value='NULL' "+strSel+">Seleccione una opcion</option>";
				foreach (DataRow r2 in dtDeptos.Rows)
				{
						strSel="";
					if(r2["Departamento"].ToString() == r["Departamento"].ToString() ){
						strSel="selected";
					} 
						opcionesDptos+="<option value='"+r2["Departamento"]+"' "+strSel+">"+r2["Departamento"]+"</option>"; 
				}
				cont++;
                tablaAreas += "<tr class='text-center' style='font-size: 13px;'>"
								+"<td><select id='tmpDepa_"+cont+"' name='tmpDepa_"+cont+"'>"+opcionesDptos+"</select></td>"
                                + "<td><input type='hidden' id='hdnArea_"+cont+"' name='hdnArea_"+cont+"' value='" + r["area"].ToString() +"'>" + r["area"].ToString() + "</td>"
                                + "<td><img src='img/basura.png' height='20' width='20' onclick='EliminarArea(\"" + r["area"].ToString().Replace(" ","") + "\");' /><input type='hidden' name='" + r["area"].ToString().Replace(" ","") + "' id='" + r["area"].ToString().Replace(" ", "") + "' value='' /></td>"
                            + "</tr>";
            }

            tablaAreas += "</tbody></table>";
            
            litAreas.Text = tablaAreas;
        }
        else
        {
            litAreas.Text = "";
        }
    }
	
	protected void btnGuardar_Click(object sender, EventArgs e){
		// guardar
		litDebug.Visible=false;
		foreach(string k in Request.Form.AllKeys.ToList().Where(n=>n.StartsWith("hdn")).ToList()){
			string area=k;
			string depa= area.Replace("hdnArea","tmpDepa");
			string qryUpdate="UPDATE [DisciplinasOperacionales].[dbo].[Areas] "
			+ " SET Departamento ='"+ Request.Form[depa] +"'"
			+ " WHERE area ='"+ Request.Form[area]+"'";
			 sql.exec(qryUpdate);
			litDebug.Text+=qryUpdate+"<br>";
			litDebug.Visible=false;
		}
		//litDebug.Text="Supongamos que se guardo";
		litAreas.Text="";
		MostrarAreasCargadas();
	}
    protected void btnEliminar_Click(object sender, EventArgs e)
    {
        dtAreas = sql.selec("SELECT * FROM [DisciplinasOperacionales].[dbo].[Areas] WHERE planta = '" + lblPlanta.Text + "' AND activo = 'True' ORDER BY area");

        if (dtAreas.Rows.Count > 0)
        {
            foreach (DataRow r in dtAreas.Rows)
            {
                if (Request.Form[r["area"].ToString().Replace(" ","")] != null && Request.Form[r["area"].ToString().Replace(" ", "")] != "")
                {
                    sql.exec("UPDATE [DisciplinasOperacionales].[dbo].[Areas] SET activo = 'False' WHERE area = '" + r["area"].ToString() + "' AND planta = '" + lblPlanta.Text + "'");
                    sql.exec("DELETE FROM [DisciplinasOperacionales].[dbo].[Agenda] WHERE area = '" + r["area"].ToString() + "' AND planta = '" + lblPlanta.Text + "' AND [status] = 'Pendiente'");
                }
            }

            litMensaje.Text = "<script>swal({title: '', text: 'Se ha eliminado el área correctamente.',type: 'success', confirmButtonClass: 'btn-success', confirmButtonText: 'OK', closeOnConfirm: false},function(){  window.location.href = 'Areas.aspx?us=" + lblUsuario.Text + "&nombre=" + lblNombre.Text + "&p=" + lblPlanta.Text + "'; });</script>";
        }
    }
}