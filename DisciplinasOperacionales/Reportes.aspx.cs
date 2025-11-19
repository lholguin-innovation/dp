using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

public partial class Reportes : System.Web.UI.Page
{
    public ConSQL sql;
    public DataTable dtTotalAreas, dtTotalAsistencias;
    public string tablaTotalAreas = "", tablaTotalAsistencias = "", claseTotal = "", okW1 = "", okW2 = "", okW3 = "", okW4 = "", okW5 = "",
        linkHistorialW1 = "", linkHistorialW2 = "", linkHistorialW3 = "", linkHistorialW4 = "", linkHistorialW5 = "", tituloExcel = "Evaluacion Disciplinas Operacionales", tituloReportes = "Scorecard Plantas";
    public int year, mes;
    protected void Page_Load(object sender, EventArgs e)
    {
        Credenciales();

        sql = new ConSQL(Env.getAppServerDbConnectionString("DisciplinasOperacionales"));

        if (!IsPostBack)
        {
            sql.llenaDropDownList(ddlPlanta, sql.selec("SELECT DISTINCT planta FROM [CatPlantas].[dbo].[Cat_Plantas] WHERE planta NOT IN ('RBE XXI','Vicente Guerrero','Guadalupe III Sat.','MECA','PMS','RBE X')"), "planta", "planta");
            ddlPlanta.SelectedIndex = ddlPlanta.Items.IndexOf(ddlPlanta.Items.FindByValue(lblPlanta.Text));
            txtMes.Text = DateTime.Now.ToString("yyyy-MM");
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
        if (txtMes.Text != "")
        {
            mes = Convert.ToInt32(DateTime.Parse(txtMes.Text).Month);
            year = Convert.ToInt32(DateTime.Parse(txtMes.Text).Year);

            //Consulta Total de Areas
            dtTotalAreas = sql.selec("SELECT * FROM [DisciplinasOperacionales].[dbo].[TotalAreas]('" + ddlPlanta.SelectedItem.Text + "', " + mes + ", " + year + ")");

            tituloReportes = "Scorecard (" + ddlPlanta.SelectedItem.Text + ", " + ObtenerMes(mes) + " " + year + ")";

            //Crea la tabla
            tablaTotalAreas += "<div class='col-sm-12 table-responsive'><table class='table' id='tablaReportes' width='100%'>"
                                + "<thead>"
                                    + "<tr class='tr-tipoOSA text-center' style='font-size: 13px;'>"
                                        + "<th></th>"
                                        + "<th></th>"
                                        + "<th>W1</th>"
                                        + "<th>W2</th>"
                                        + "<th>W3</th>"
                                        + "<th>W4</th>"
                                        + "<th>W5</th>"
                                        + "<th>Promedio Mes</th>"
                                    + "</tr>"
                                + "</thead>"
                                + "<tbody style='font-size: 12px;'>";

            if (dtTotalAreas.Rows.Count > 0)
            {
                //Titulo del resultado por areas
                tablaTotalAreas += "<tr class='tr-elemento' style='font-size: 12px;'>"
                                        + "<td></td>"
                                        + "<td>Area</td>"
                                        + "<td></td>"
                                        + "<td></td>"
                                        + "<td></td>"
                                        + "<td></td>"
                                        + "<td></td>"
                                        + "<td></td>"
                                    + "</tr>";

                foreach (DataRow r in dtTotalAreas.Rows)
                {
                    if (r["area"].ToString() == "TOTAL")
                    {
                        claseTotal = "font-weight-bold";
                    }

                    if (r["W1"].ToString() != "0" && r["area"].ToString() != "TOTAL")
                    {
                        linkHistorialW1 = "<a style='text-decoration: none;' class='" + ObtenerColor(Convert.ToSingle(r["W1"].ToString())) + "' href='Historial.aspx?us=" + lblUsuario.Text + "&nombre=" + lblNombre.Text + "&p=" + lblPlanta.Text + "&p_sel=" + ddlPlanta.SelectedItem.Text + "&area=" + r["area"].ToString().Replace("&", "%26") + "&year=" + year + "&mes=" + mes + "&week=1'>" + r["W1"].ToString() + "%</a>";
                    }
                    else
                    {
                        linkHistorialW1 = r["W1"].ToString() + "%";
                    }

                    if (r["W2"].ToString() != "0" && r["area"].ToString() != "TOTAL")
                    {
                        linkHistorialW2 = "<a style='text-decoration: none;' class='" + ObtenerColor(Convert.ToSingle(r["W2"].ToString())) + "' href='Historial.aspx?us=" + lblUsuario.Text + "&nombre=" + lblNombre.Text + "&p=" + lblPlanta.Text + "&p_sel=" + ddlPlanta.SelectedItem.Text + "&area=" + r["area"].ToString().Replace("&", "%26") + "&year=" + year + "&mes=" + mes + "&week=2'>" + r["W2"].ToString() + "%</a>";
                    }
                    else
                    {
                        linkHistorialW2 = r["W2"].ToString() + "%";
                    }

                    if (r["W3"].ToString() != "0" && r["area"].ToString() != "TOTAL")
                    {
                        linkHistorialW3 = "<a style='text-decoration: none;' class='" + ObtenerColor(Convert.ToSingle(r["W3"].ToString())) + "' href='Historial.aspx?us=" + lblUsuario.Text + "&nombre=" + lblNombre.Text + "&p=" + lblPlanta.Text + "&p_sel=" + ddlPlanta.SelectedItem.Text + "&area=" + r["area"].ToString().Replace("&", "%26") + "&year=" + year + "&mes=" + mes + "&week=3'>" + r["W3"].ToString() + "%</a>";
                    }
                    else
                    {
                        linkHistorialW3 = r["W3"].ToString() + "%";
                    }

                    if (r["W4"].ToString() != "0" && r["area"].ToString() != "TOTAL")
                    {
                        linkHistorialW4 = "<a style='text-decoration: none;' class='" + ObtenerColor(Convert.ToSingle(r["W4"].ToString())) + "' href='Historial.aspx?us=" + lblUsuario.Text + "&nombre=" + lblNombre.Text + "&p=" + lblPlanta.Text + "&p_sel=" + ddlPlanta.SelectedItem.Text + "&area=" + r["area"].ToString().Replace("&", "%26") + "&year=" + year + "&mes=" + mes + "&week=4'>" + r["W4"].ToString() + "%</a>";
                    }
                    else
                    {
                        linkHistorialW4 = r["W4"].ToString() + "%";
                    }

                    if (r["W5"].ToString() != "0" && r["area"].ToString() != "TOTAL")
                    {
                        linkHistorialW5 = "<a style='text-decoration: none;' class='" + ObtenerColor(Convert.ToSingle(r["W5"].ToString())) + "' href='Historial.aspx?us=" + lblUsuario.Text + "&nombre=" + lblNombre.Text + "&p=" + lblPlanta.Text + "&p_sel=" + ddlPlanta.SelectedItem.Text + "&area=" + r["area"].ToString().Replace("&", "%26") + "&year=" + year + "&mes=" + mes + "&week=5'>" + r["W5"].ToString() + "%</a>";
                    }
                    else
                    {
                        linkHistorialW5 = r["W5"].ToString() + "%";
                    }

                    tablaTotalAreas += "<tr>"
                                        + "<td></td>"
                                        + "<td class='" + claseTotal + "'>" + r["area"].ToString() + "</td>"
                                        + "<td style='font-size: 14px;' class='text-center font-weight-bold " + ObtenerColor(Convert.ToSingle(r["W1"].ToString())) + "'>" + linkHistorialW1 + "</td>"
                                        + "<td style='font-size: 14px;' class='text-center font-weight-bold " + ObtenerColor(Convert.ToSingle(r["W2"].ToString())) + "'>" + linkHistorialW2 + "</td>"
                                        + "<td style='font-size: 14px;' class='text-center font-weight-bold " + ObtenerColor(Convert.ToSingle(r["W3"].ToString())) + "'>" + linkHistorialW3 + "</td>"
                                        + "<td style='font-size: 14px;' class='text-center font-weight-bold " + ObtenerColor(Convert.ToSingle(r["W4"].ToString())) + "'>" + linkHistorialW4 + "</td>"
                                        + "<td style='font-size: 14px;' class='text-center font-weight-bold " + ObtenerColor(Convert.ToSingle(r["W5"].ToString())) + "'>" + linkHistorialW5 + "</td>"
                                        + "<td style='font-size: 14px;' class='text-center font-weight-bold " + ObtenerColor(Convert.ToSingle(r["mes"].ToString())) + "'>" + r["mes"].ToString() + "%</td>"
                                    + "</tr>";
                }
            }

            //Row vacio como salto de linea
            tablaTotalAreas += "<tr>"
                                + "<td></td>"
                                + "<td></td>"
                                + "<td></td>"
                                + "<td></td>"
                                + "<td></td>"
                                + "<td></td>"
                                + "<td></td>"
                                + "<td></td>"
                            + "</tr>";

            claseTotal = "";

            //------------------------------------------------------------------------------------------

            //Consulta Total de Asistencia
            dtTotalAsistencias = sql.selec("SELECT participante, nombre, W1, W2, W3, W4, W5, total FROM [DisciplinasOperacionales].[dbo].[TotalAsistencia]('" + ddlPlanta.SelectedItem.Text + "'," + mes + "," + year + ") A "
                                            + "LEFT JOIN "
                                            + "(SELECT dpto, nombre FROM[DisciplinasOperacionales].[dbo].[Staff] WHERE planta = '" + ddlPlanta.SelectedItem.Text + "' AND nombre <> '') B "
                                            + "ON A.participante = B.dpto");

            if (dtTotalAsistencias.Rows.Count > 0)
            {
                //Titulo del resultado total de asistencia
                tablaTotalAsistencias += "<tr class='tr-elemento' style='font-size: 12px;'>"
                                            + "<td></td>"
                                            + "<td>Asistencia</td>"
                                            + "<td></td>"
                                            + "<td></td>"
                                            + "<td></td>"
                                            + "<td></td>"
                                            + "<td></td>"
                                            + "<td></td>"
                                        + "</tr>";

                foreach (DataRow r in dtTotalAsistencias.Rows)
                {
                    if (r["participante"].ToString() == "TOTAL")
                    {
                        claseTotal = "font-weight-bold";

                        tablaTotalAsistencias += "<tr>"
                                                + "<td></td>"
                                                + "<td class='" + claseTotal + "'>" + r["participante"].ToString() + "</td>"
                                                + "<td style='font-size: 14px;' class='text-center font-weight-bold " + ObtenerColor(Convert.ToSingle(r["W1"].ToString())) + "'>" + r["W1"].ToString() + "%</td>"
                                                + "<td style='font-size: 14px;' class='text-center font-weight-bold " + ObtenerColor(Convert.ToSingle(r["W2"].ToString())) + "'>" + r["W2"].ToString() + "%</td>"
                                                + "<td style='font-size: 14px;' class='text-center font-weight-bold " + ObtenerColor(Convert.ToSingle(r["W3"].ToString())) + "'>" + r["W3"].ToString() + "%</td>"
                                                + "<td style='font-size: 14px;' class='text-center font-weight-bold " + ObtenerColor(Convert.ToSingle(r["W4"].ToString())) + "'>" + r["W4"].ToString() + "%</td>"
                                                + "<td style='font-size: 14px;' class='text-center font-weight-bold " + ObtenerColor(Convert.ToSingle(r["W5"].ToString())) + "'>" + r["W5"].ToString() + "%</td>"
                                                + "<td style='font-size: 14px;' class='text-center font-weight-bold " + ObtenerColor(Convert.ToSingle(r["total"].ToString())) + "'>" + r["total"].ToString() + "%</td>"
                                            + "</tr>";
                    }
                    else
                    {
                        if (r["W1"].ToString() == "1") { okW1 = "<i class='fa fa-check'></i>"; } else { okW1 = "<i class='fa fa-times'></i>"; }
                        if (r["W2"].ToString() == "1") { okW2 = "<i class='fa fa-check'></i>"; } else { okW2 = "<i class='fa fa-times'></i>"; }
                        if (r["W3"].ToString() == "1") { okW3 = "<i class='fa fa-check'></i>"; } else { okW3 = "<i class='fa fa-times'></i>"; }
                        if (r["W4"].ToString() == "1") { okW4 = "<i class='fa fa-check'></i>"; } else { okW4 = "<i class='fa fa-times'></i>"; }
                        if (r["W5"].ToString() == "1") { okW5 = "<i class='fa fa-check'></i>"; } else { okW5 = "<i class='fa fa-times'></i>"; }

                        tablaTotalAsistencias += "<tr>"
                                                + "<td></td>"
                                                + "<td class='" + claseTotal + "'>" + r["nombre"].ToString() + "&nbsp;&nbsp;(" + r["participante"].ToString() + ")</td>"
                                                + "<td style='font-size: 14px;' class='text-center font-weight-bold'>" + okW1 + "</td>"
                                                + "<td style='font-size: 14px;' class='text-center font-weight-bold'>" + okW2 + "</td>"
                                                + "<td style='font-size: 14px;' class='text-center font-weight-bold'>" + okW3 + "</td>"
                                                + "<td style='font-size: 14px;' class='text-center font-weight-bold'>" + okW4 + "</td>"
                                                + "<td style='font-size: 14px;' class='text-center font-weight-bold'>" + okW5 + "</td>"
                                                + "<td style='font-size: 14px;' class='text-center font-weight-bold " + ObtenerColor(Convert.ToSingle(r["total"].ToString())) + "'>" + r["total"].ToString() + "%</td>"
                                            + "</tr>";
                    }                    
                }
            }

            litReportes.Text = tablaTotalAreas + tablaTotalAsistencias + "</tbody></table></div>";
            tituloExcel = "Evaluacion Disciplinas Operacionales " + ddlPlanta.SelectedItem.Text + " " + ObtenerMes(mes) + " " + year;
        }
    }

    public string ObtenerMes(int m)
    {
        string mes = "";

        switch (m)
        {
            case 1:
                mes = "Enero";
                break;
            case 2:
                mes = "Febrero";
                break;
            case 3:
                mes = "Marzo";
                break;
            case 4:
                mes = "Abril";
                break;
            case 5:
                mes = "Mayo";
                break;
            case 6:
                mes = "Junio";
                break;
            case 7:
                mes = "Julio";
                break;
            case 8:
                mes = "Agosto";
                break;
            case 9:
                mes = "Septiembre";
                break;
            case 10:
                mes = "Octubre";
                break;
            case 11:
                mes = "Noviembre";
                break;
            case 12:
                mes = "Diciembre";
                break;
        }

        return mes;
    }

    public string ObtenerColor(float porcentaje)
    {
        string color = "";

        if (porcentaje < 95)
        {
            color = "text-danger";
        }
        if (porcentaje >= 95 && porcentaje < 98)
        {
            color = "text-warning";
        }
        if (porcentaje >= 98)
        {
            color = "text-success";
        }
        if (porcentaje == 0)
        {
            color = "";
        }

        return color;
    }
}