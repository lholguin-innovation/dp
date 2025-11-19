using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

public partial class Responsables : System.Web.UI.Page
{
    public ConSQL sql;
    public DataTable dtDptos, dtAsignacion;
    public DataRow[] rows;
    public string tablaDptos = "", nombre = "", correo = "";
    public int hayAsignacion;

    protected void Page_Load(object sender, EventArgs e)
    {
        Credenciales();

        //sql = new ConSQL("Server=10.223.36.253\\SQLExpress;Database=DisciplinasOperacionales;Uid=sa;Pwd=99552499*;pooling=false;");
        sql = new ConSQL(Env.getAppServerDbConnectionString("DisciplinasOperacionales"));

        if (!IsPostBack)
        {
            MostrarDptos();
        }
        else
        {
            MostrarDptos();
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

    public void MostrarDptos()
    {
        dtDptos = sql.selec("SELECT * FROM [DisciplinasOperacionales].[dbo].[Dptos] ORDER BY dpto");

        if (dtDptos.Rows.Count > 0)
        {
            tablaDptos += "<table id='tablaDptos' class='table' width='100%'>"
                            + "<thead>"
                                + "<tr class='tr-tipoOSA text-center' style='font-size: 13px;'>"
                                    + "<th>Departamento</th>"
                                    + "<th>Planta</th>"
                                    + "<th>Responsable</th>"
                                    + "<th>Correo</th>"
                                + "</tr>"
                            + "</thead>"
                            + "<tbody>";

            dtAsignacion = sql.selec("SELECT * FROM [DisciplinasOperacionales].[dbo].[Staff] WHERE planta = '" + lblPlanta.Text + "' ORDER BY dpto");

            foreach (DataRow r in dtDptos.Rows)
            {
                rows = dtAsignacion.Select("dpto = '" + r["dpto"].ToString() + "'");

                if (rows.Length > 0)
                {
                    tablaDptos += "<tr class='text-center' style='font-size: 13px;'>"
                                    + "<td>" + r["dpto"].ToString() + "</td>"
                                    + "<td>" + lblPlanta.Text + "</td>"
                                    + "<td><input style='font-size: 13px;' id='nombre" + r["id"].ToString() + "' name='nombre" + r["id"].ToString() + "' class='form-control' type='text' value='" + rows[0]["nombre"].ToString() + "' /></td>"
                                    + "<td><input style='font-size: 13px;' id='correo" + r["id"].ToString() + "' name='correo" + r["id"].ToString() + "' class='form-control' type='text' value='" + rows[0]["correo"].ToString() + "' /></td>"
                                + "</tr>";
                }
                else
                {
                    tablaDptos += "<tr class='text-center' style='font-size: 13px;'>"
                                    + "<td>" + r["dpto"].ToString() + "</td>"
                                    + "<td>" + lblPlanta.Text + "</td>"
                                    + "<td><input style='font-size: 13px;' id='nombre" + r["id"].ToString() + "' name='nombre" + r["id"].ToString() + "' class='form-control' type='text' /></td>"
                                    + "<td><input style='font-size: 13px;' id='correo" + r["id"].ToString() + "' name='correo" + r["id"].ToString() + "' class='form-control' type='text' /></td>"
                                + "</tr>";
                }
            }

            tablaDptos += "</tbody></table>";

            litDptos.Text = tablaDptos;
            btnActualizar.Visible = true;
        }
        else
        {
            litDptos.Text = "";
            btnActualizar.Visible = false;
        }
    }

    protected void btnActualizar_Click(object sender, EventArgs e)
    {
        dtDptos = sql.selec("SELECT * FROM [DisciplinasOperacionales].[dbo].[Dptos] ORDER BY dpto");

        if (dtDptos.Rows.Count > 0)
        {
            foreach (DataRow r in dtDptos.Rows)
            {
                nombre = "nombre" + r["id"].ToString();
                correo = "correo" + r["id"].ToString();

                hayAsignacion = Convert.ToInt32(sql.scalar("SELECT COUNT(*) cant FROM [DisciplinasOperacionales].[dbo].[Staff] WHERE dpto = '" + r["dpto"].ToString() + "' AND planta = '" + lblPlanta.Text + "'"));

                if (hayAsignacion > 0)
                {
                    if (Request.Form[nombre] != null && Request.Form[nombre] != "")
                    {
                        sql.exec("UPDATE [DisciplinasOperacionales].[dbo].[Staff] SET nombre = '" + Request.Form[nombre] + "', correo = '" + Request.Form[correo].ToLower() + "', usuario_mod = '" + lblNombre.Text + "', fh_mod = GETDATE() WHERE dpto = '" + r["dpto"].ToString() + "' AND planta = '" + lblPlanta.Text + "'");
                    }
                    else
                    {
                        sql.exec("UPDATE [DisciplinasOperacionales].[dbo].[Staff] SET nombre = '', correo = '', usuario_mod = '" + lblNombre.Text + "', fh_mod = GETDATE() WHERE dpto = '" + r["dpto"].ToString() + "' AND planta = '" + lblPlanta.Text + "'");
                    }
                }
                else
                {
                    if (Request.Form[nombre] != null)
                    {
                        sql.exec("INSERT INTO [DisciplinasOperacionales].[dbo].[Staff] (dpto, nombre, correo, planta, usuario) VALUES ('" + r["dpto"].ToString() + "','" + Request.Form[nombre] + "','" + Request.Form[correo].ToLower() + "','" + lblPlanta.Text + "','" + lblNombre.Text + "')");
                    }
                }
            }

            litMensaje.Text = "<script>swal({title: '', text: 'Las asignaciones se han guardado correctamente.',type: 'success', confirmButtonClass: 'btn-success', confirmButtonText: 'OK', closeOnConfirm: false},function(){  window.location.href = 'Responsables.aspx?&us=" + lblUsuario.Text + "&nombre=" + lblNombre.Text + "&p=" + lblPlanta.Text + "'; });</script>";
        }
    }
}