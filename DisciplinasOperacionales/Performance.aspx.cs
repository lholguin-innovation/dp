using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

public partial class Performance : System.Web.UI.Page
{
    public ConSQL sql;
    public DataTable dtPerformance, dtPerformanceChart;
    public string tabla = "", datosPerformance = "", tituloChart = "";

    protected void Page_Load(object sender, EventArgs e)
    {
        Credenciales();

        sql = new ConSQL(Env.getAppServerDbConnectionString("DisciplinasOperacionales"));

        if (!IsPostBack)
        {
            sql.llenaDropDownList(ddlYear, sql.selec("SELECT DISTINCT DATEPART(YEAR,fh) y FROM [DisciplinasOperacionales].[dbo].[Historial] ORDER BY y DESC"), "y", "y");
            ddlMes.Items.Add(new ListItem("YTD", "YTD"));
            ddlMes.Items.Add(new ListItem("Enero", "E"));
            ddlMes.Items.Add(new ListItem("Febrero", "F"));
            ddlMes.Items.Add(new ListItem("Marzo", "Mz"));
            ddlMes.Items.Add(new ListItem("Abril", "Ab"));
            ddlMes.Items.Add(new ListItem("Mayo", "My"));
            ddlMes.Items.Add(new ListItem("Junio", "Jn"));
            ddlMes.Items.Add(new ListItem("Julio", "Jl"));
            ddlMes.Items.Add(new ListItem("Agosto", "Ag"));
            ddlMes.Items.Add(new ListItem("Septiembre", "S"));
            ddlMes.Items.Add(new ListItem("Octubre", "O"));
            ddlMes.Items.Add(new ListItem("Noviembre", "N"));
            ddlMes.Items.Add(new ListItem("Diciembre", "D"));
            btnMostrar_Click(sender, e);
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

    protected void btnMostrar_Click(object sender, EventArgs e)
    {
        if (ddlYear.Items.Count > 0)
        {
            dtPerformance = sql.selec("SELECT * FROM [DisciplinasOperacionales].[dbo].[ResumenTotal](" + ddlYear.SelectedItem.Text + ")");

            if (dtPerformance.Rows.Count > 0)
            {
                tabla += "<table id='tablaPerformance' class='table table-bordered' width='100%'>"
                            + "<thead>"
                                + "<tr class='tr-tipoOSA text-center'>"
                                    + "<th>Planta</th>"
                                    + "<th>E</th>"
                                    + "<th>F</th>"
                                    + "<th>M</th>"
                                    + "<th>A</th>"
                                    + "<th>M</th>"
                                    + "<th>J</th>"
                                    + "<th>J</th>"
                                    + "<th>A</th>"
                                    + "<th>S</th>"
                                    + "<th>O</th>"
                                    + "<th>N</th>"
                                    + "<th>D</th>"
                                    + "<th>YTD</th>"
                                + "</tr>"
                            + "</thead>"
                            + "<tbody>";

                foreach (DataRow r in dtPerformance.Rows)
                {
                    if (r["planta"].ToString() != "Total")
                    {
                        tabla += "<tr>"
                                + "<td style='font-size: 13px;'>" + r["planta"].ToString() + "</td>"
                                + "<td class='text-center " + ObtenerColor(Convert.ToSingle(r["E"])) + "'>" + r["E"].ToString() + "</td>"
                                + "<td class='text-center " + ObtenerColor(Convert.ToSingle(r["F"])) + "'>" + r["F"].ToString() + "</td>"
                                + "<td class='text-center " + ObtenerColor(Convert.ToSingle(r["Mz"])) + "'>" + r["Mz"].ToString() + "</td>"
                                + "<td class='text-center " + ObtenerColor(Convert.ToSingle(r["Ab"])) + "'>" + r["Ab"].ToString() + "</td>"
                                + "<td class='text-center " + ObtenerColor(Convert.ToSingle(r["My"])) + "'>" + r["My"].ToString() + "</td>"
                                + "<td class='text-center " + ObtenerColor(Convert.ToSingle(r["Jn"])) + "'>" + r["Jn"].ToString() + "</td>"
                                + "<td class='text-center " + ObtenerColor(Convert.ToSingle(r["Jl"])) + "'>" + r["Jl"].ToString() + "</td>"
                                + "<td class='text-center " + ObtenerColor(Convert.ToSingle(r["Ag"])) + "'>" + r["Ag"].ToString() + "</td>"
                                + "<td class='text-center " + ObtenerColor(Convert.ToSingle(r["S"])) + "'>" + r["S"].ToString() + "</td>"
                                + "<td class='text-center " + ObtenerColor(Convert.ToSingle(r["O"])) + "'>" + r["O"].ToString() + "</td>"
                                + "<td class='text-center " + ObtenerColor(Convert.ToSingle(r["N"])) + "'>" + r["N"].ToString() + "</td>"
                                + "<td class='text-center " + ObtenerColor(Convert.ToSingle(r["D"])) + "'>" + r["D"].ToString() + "</td>"
                                + "<td class='text-center " + ObtenerColor(Convert.ToSingle(r["YTD"])) + "'>" + r["YTD"].ToString() + "</td>"
                            + "</tr>";
                    }
                    else
                    {
                        tabla += "<tr class='tr-elemento'>"
                                   + "<td style='font-size: 14px;'>TOTAL</td>"
                                   + "<td class='text-center " + ObtenerColor(Convert.ToSingle(r["E"])) + "'>" + r["E"].ToString() + "</td>"
                                   + "<td class='text-center " + ObtenerColor(Convert.ToSingle(r["F"])) + "'>" + r["F"].ToString() + "</td>"
                                   + "<td class='text-center " + ObtenerColor(Convert.ToSingle(r["Mz"])) + "'>" + r["Mz"].ToString() + "</td>"
                                   + "<td class='text-center " + ObtenerColor(Convert.ToSingle(r["Ab"])) + "'>" + r["Ab"].ToString() + "</td>"
                                   + "<td class='text-center " + ObtenerColor(Convert.ToSingle(r["My"])) + "'>" + r["My"].ToString() + "</td>"
                                   + "<td class='text-center " + ObtenerColor(Convert.ToSingle(r["Jn"])) + "'>" + r["Jn"].ToString() + "</td>"
                                   + "<td class='text-center " + ObtenerColor(Convert.ToSingle(r["Jl"])) + "'>" + r["Jl"].ToString() + "</td>"
                                   + "<td class='text-center " + ObtenerColor(Convert.ToSingle(r["Ag"])) + "'>" + r["Ag"].ToString() + "</td>"
                                   + "<td class='text-center " + ObtenerColor(Convert.ToSingle(r["S"])) + "'>" + r["S"].ToString() + "</td>"
                                   + "<td class='text-center " + ObtenerColor(Convert.ToSingle(r["O"])) + "'>" + r["O"].ToString() + "</td>"
                                   + "<td class='text-center " + ObtenerColor(Convert.ToSingle(r["N"])) + "'>" + r["N"].ToString() + "</td>"
                                   + "<td class='text-center " + ObtenerColor(Convert.ToSingle(r["D"])) + "'>" + r["D"].ToString() + "</td>"
                                   + "<td class='text-center " + ObtenerColor(Convert.ToSingle(r["YTD"])) + "'>" + r["YTD"].ToString() + "</td>"
                               + "</tr>";
                    }
                }

                tabla += "</tbody></table>";
                litScorecard.Text = tabla;

                if (ddlMes.SelectedItem.Value == "YTD")
                {
                    dtPerformanceChart = sql.selec("SELECT planta, YTD FROM (SELECT * FROM [DisciplinasOperacionales].[dbo].[ResumenTotal](" + ddlYear.SelectedItem.Text + ") WHERE planta <> 'Total') A ORDER BY YTD DESC");
                    tituloChart = "YTD " + ddlYear.SelectedItem.Text;
                }
                else
                {
                    dtPerformanceChart = sql.selec("SELECT planta, " + ddlMes.SelectedItem.Value + " FROM (SELECT * FROM [DisciplinasOperacionales].[dbo].[ResumenTotal](" + ddlYear.SelectedItem.Text + ") WHERE planta <> 'Total') A ORDER BY " + ddlMes.SelectedItem.Value + " DESC");
                    tituloChart = ddlMes.SelectedItem.Text + " " + ddlYear.SelectedItem.Text;
                }

                if (dtPerformanceChart.Rows.Count > 0)
                {
                    foreach (DataRow r in dtPerformanceChart.Rows)
                    {
                        datosPerformance += "{ label: '" + r["planta"].ToString() + "', value: '" + r[ddlMes.SelectedItem.Value].ToString() + "', color: '" + ObtenerColorGrafica(Convert.ToSingle(r[ddlMes.SelectedItem.Value].ToString())) + "' },";
                    }

                    datosPerformance = datosPerformance.Remove(datosPerformance.Length - 1, 1);
                    chartPerformance.Visible = true;
                }
                else
                {
                    chartPerformance.Visible = false;
                }
            }
        }
    }

    public string ObtenerColor(float porcentaje)
    {
        string color = "";

        if (porcentaje < 95)
        {
            color = "bg-danger text-white";
        }
        if (porcentaje >= 95 && porcentaje < 98)
        {
            color = "bg-warning text-dark";
        }
        if (porcentaje >= 98)
        {
            color = "bg-success text-white";
        }
        if (porcentaje == 0)
        {
            color = "";
        }

        return color;
    }

    public string ObtenerColorGrafica(float porcentaje)
    {
        string color = "";

        if (porcentaje < 95)
        {
            color = "#dc3545";
        }
        if (porcentaje >= 95 && porcentaje < 98)
        {
            color = "#ffc107";
        }
        if (porcentaje >= 98)
        {
            color = "#28a745";
        }
        if (porcentaje == 0)
        {
            color = "";
        }

        return color;
    }
}