using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

public partial class Resumen : System.Web.UI.Page
{
    public ConSQL sql;
    public DataTable dtResultadoMensual, dtPerformance, dtRegion, dtPlantas, dtItems, dtResultadoMensualPlantas;
    public string cardsRegion = "", dataResultadoMensual = "", performance = "", plantas = "", performance_plantas = "", implementacion = "",
        fechaPlanes = "", periodoPlanes = "", jsonPlanes = "", dataPlanes = "", tituloPlanes = "", items = "", dataResultadoMensualPlantas = "", categoria = "", 
		serieFY = "", serieMensual = "", print;
    public int bloques, year_ant;

    protected void Page_Load(object sender, EventArgs e)
    {
        Credenciales();

        sql = new ConSQL(Env.getAppServerDbConnectionString("DisciplinasOperacionales"));

        if (!IsPostBack)
        {
            sql.llenaDropDownList(ddlYear, sql.selec("SELECT DISTINCT DATEPART(YEAR,fh_registro) y FROM [DisciplinasOperacionales].[dbo].[Historial] ORDER BY y DESC"), "y", "y");
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
            if (Request.QueryString["p"] == "") 
            {
                lblPlanta.Text  = Session["Planta"].ToString();                
            }
            else 
                {
                lblPlanta.Text  = Request.QueryString["p"];
                }
            
        }catch(Exception ex){
      Response.Redirect(Env.redirectUrl);
        }
    }

    protected void btnMostrar_Click(object sender, EventArgs e)
    {
        if (ddlYear.Items.Count > 0)
        {
            year_ant = Convert.ToInt32(ddlYear.SelectedItem.Text) - 1;

            dtResultadoMensual = sql.selec("SELECT mes, resultado, CASE WHEN resultado >= 98 THEN '#28a745' WHEN resultado BETWEEN 95 AND 97.9 THEN '#ffc107' ELSE '#dc3545' END color FROM "
                                        + "(SELECT [FY " + year_ant + "], [FY " + ddlYear.SelectedItem.Text + "], Enero, Febrero, Marzo, Abril, Mayo, Junio, Julio, Agosto, Septiembre, Octubre, Noviembre, Diciembre FROM "
                                        + "(SELECT [YTD] [FY " + ddlYear.SelectedItem.Text + "], [E] Enero, [F] Febrero, [Mz] Marzo, [Ab] Abril, [My] Mayo, [Jn] Junio, [Jl] Julio, [Ag] Agosto, [S] Septiembre, [O] Octubre, [N] Noviembre, [D] Diciembre FROM[DisciplinasOperacionales].[dbo].[ResumenTotal](" + ddlYear.SelectedItem.Text + ") WHERE id = 5) A "
                                        + "CROSS JOIN "
                                        + "(SELECT [YTD] [FY " + year_ant + "] FROM[DisciplinasOperacionales].[dbo].[ResumenTotal](" + year_ant + ") WHERE id = 5) B) A "
                                        + "UNPIVOT "
                                        + "(resultado FOR mes IN([FY " + year_ant + "],[FY " + ddlYear.SelectedItem.Text + "],[Enero],[Febrero],[Marzo],[Abril],[Mayo],[Junio],[Julio],[Agosto],[Septiembre],[Octubre],[Noviembre],[Diciembre])) B");
										
													

            performance = sql.scalar("SELECT " + ddlMes.SelectedItem.Value + " FROM (SELECT * FROM [DisciplinasOperacionales].[dbo].[ResumenTotal](" + ddlYear.SelectedItem.Text + ") WHERE id = 5) A").ToString();
			
			

            dtRegion = sql.selec("SELECT *, CASE WHEN total >= 98 THEN 'success' WHEN total BETWEEN 95.1 AND 97.9 THEN 'warning' ELSE 'danger' END class FROM (SELECT id, region, ROUND(AVG(" + ddlMes.SelectedItem.Value + "),1) total FROM "
                                + "(SELECT id, CASE WHEN id = 1 THEN 'North' WHEN id = 2 THEN 'West' WHEN id = 3 THEN 'East' WHEN id = 4 THEN 'Center' WHEN id = 6 THEN 'SA' END region, " + ddlMes.SelectedItem.Value + " FROM "
                                + "(SELECT * FROM [DisciplinasOperacionales].[dbo].[Resumen](" + ddlYear.SelectedItem.Text + ") WHERE planta<>'VICTORIA I') A) B GROUP BY id, region) C ORDER BY id");
								
								
								

            dtPlantas = sql.selec("SELECT planta, implementacion, ROUND(" + ddlMes.SelectedItem.Value + ",0) " + ddlMes.SelectedItem.Value + ", CASE WHEN implementacion >= 98 THEN '#28a745' WHEN implementacion BETWEEN 94.5 AND 97.9 THEN '#ffc107' ELSE '#dc3545' END color_imp, CASE WHEN " + ddlMes.SelectedItem.Value + " >= 97.5 THEN '#28a745' WHEN " + ddlMes.SelectedItem.Value + " BETWEEN 94.5 AND 97.4 THEN '#ffc107' ELSE '#dc3545' END color_per FROM "
                                + "(SELECT A.planta, ISNULL(B.implementacion, 0) implementacion, " + ddlMes.SelectedItem.Value + " FROM [DisciplinasOperacionales].[dbo].[Resumen](" + ddlYear.SelectedItem.Text + ") A "
                                + "LEFT JOIN (SELECT DISTINCT planta, 100 implementacion FROM [DisciplinasOperacionales].[dbo].[Historial]) B ON A.planta = B.planta) C  WHERE planta<>'Victoria I' ORDER BY implementacion DESC, " + ddlMes.SelectedItem.Value + " DESC");
								
								
								

            dtItems = sql.selec("SELECT *, CASE WHEN performance >= 98 THEN 'success' WHEN performance BETWEEN 95.1 AND 97.9 THEN 'warning' ELSE 'danger' END class FROM "
                            + "(SELECT D.id, C.codigo, D.elemento, D.disciplina, ROUND(([OK] /[total]) * 100, 1) performance FROM "
                            + "(SELECT codigo, CONVERT(FLOAT,[OK])[OK], CONVERT(FLOAT,[NOK])[NOK], CONVERT(FLOAT, ([OK] +[NOK])) total FROM "
                            + "(SELECT codigo, COUNT(CASE WHEN respuesta = 'OK' THEN respuesta END)[OK], COUNT(CASE WHEN respuesta = 'NOK' THEN respuesta END)[NOK] FROM "
                            + "(SELECT codigo, respuesta FROM [DisciplinasOperacionales].[dbo].[Evaluacion] WHERE DATEPART(YEAR, fh) = " + ddlYear.SelectedItem.Text + " " + FiltroMes() + ") A GROUP BY codigo) B) C "
                            + "LEFT JOIN "
                            + "(SELECT id, codigo, elemento, disciplina FROM[DisciplinasOperacionales].[dbo].[Disciplinas]) D "
                            + "ON C.codigo = D.codigo) E ORDER BY performance");
							
							

            dtResultadoMensualPlantas = sql.selec("SELECT planta, mes, resultado FROM "
                            + "(SELECT planta, [E] Enero, [F] Febrero, [Mz] Marzo, [Ab] Abril, [My] Mayo, [Jn] Junio, [Jl] Julio, [Ag] Agosto, [S] Septiembre, [O] Octubre, [N] Noviembre, [D] Diciembre FROM [DisciplinasOperacionales].[dbo].[ResumenTotal](" + ddlYear.SelectedItem.Text + ")) A"
                            + " UNPIVOT "
                            + "(resultado FOR mes IN ([Enero],[Febrero],[Marzo],[Abril],[Mayo],[Junio],[Julio],[Agosto],[Septiembre],[Octubre],[Noviembre],[Diciembre])) B");

            if (dtResultadoMensual.Rows.Count > 0)
            {
                foreach (DataRow r in dtResultadoMensual.Rows)
                {
                    if (r["mes"].ToString().Contains("FY"))
                    {
                        categoria += "{'label':'" + r["mes"].ToString() + "'},";
                        serieFY += "{'value':'" + r["resultado"].ToString() + "', 'color':'" + r["color"].ToString() + "'},";
                        serieMensual += "{'anchorBorderColor':'" + r["color"].ToString() + "', 'anchorBgColor':'" + r["color"].ToString() + "'},";
                    }
                    else
                    {
                        categoria += "{'label':'" + r["mes"].ToString() + "'},";
                        serieMensual += "{'value': '" + r["resultado"].ToString() + "', 'anchorBorderColor': '" + r["color"].ToString() + "', 'anchorBgColor': '" + r["color"].ToString() + "'},";
                    }
                }

                categoria = categoria.Remove(categoria.Length - 1, 1);
                serieFY = serieFY.Remove(serieFY.Length - 1, 1);
                serieMensual = serieMensual.Remove(serieMensual.Length - 1, 1);
            }

            if (dtResultadoMensualPlantas.Rows.Count > 0)
            {
                foreach (DataRow r in dtResultadoMensualPlantas.Rows)
                {
                    dataResultadoMensualPlantas += "{ 'planta':'" + r["planta"].ToString() + "','mes':'" + r["mes"].ToString() + "','resultado':'" + r["resultado"].ToString() + "','color':'" + ObtenerColor(Convert.ToSingle(r["resultado"].ToString())) + "' },";
                }

                dataResultadoMensualPlantas = dataResultadoMensualPlantas.Remove(dataResultadoMensualPlantas.Length - 1, 1);
            }

            if (dtRegion.Rows.Count > 0)
            {
                foreach (DataRow r in dtRegion.Rows)
                {
                    cardsRegion += "<div class='card card-gray'>"
                                    + "<div class='card-header'>"
                                        + "<div class='header-block'>"
                                            + "<p class='title' style='color: black;'> " + r["region"].ToString() + " </p>"
                                        + "</div>"
                                        + "<span class='title pull-right font-weight-bold text-" + r["class"].ToString() + "' style='margin-right: 20px;'> " + r["total"].ToString() + "% </span>"
                                    + "</div>"
                                + "</div>";
                }

                litTablaRegion.Text = cardsRegion;
            }

            if (dtPlantas.Rows.Count > 0)
            {
                foreach (DataRow r in dtPlantas.Rows)
                {
                    performance_plantas += "{ label: '" + r["planta"].ToString() + "', value: '" + r[ddlMes.SelectedItem.Value].ToString() + "', color: '" + r["color_per"].ToString() + "', placeValueInside: '1', anchorBorderColor: '" + r["color_per"].ToString() + "', anchorBgColor: '" + r["color_per"].ToString() + "' },";
                }

                performance_plantas = performance_plantas.Remove(performance_plantas.Length - 1, 1);
            }

            if (dtItems.Rows.Count > 0)
            {
                items += "<div>"
                                + "<input class='dropTableButton' type='button' id='drpdwnTbl_Bttn1' value='Generico &#9660' onclick='showhideTable(1)'/>"
                            + "<div class='dropTableDiv' id='tbl1' style='display: none'>"
                                + "<table class='table table-bordered' id='nullTable' width='100%'>"
                                    + "<thead>"
                                        + "<tr class='tr-tipoOSA'>"
                                            + "<th class='text-center align-middle'>Disciplina</th>"
                                            + "<th class='text-center align-middle'>Performance</th>"
                                        + "</tr>"
                                    + "</thead>"
                                    + "<tbody>";

                foreach (DataRow r in dtItems.Rows)
                {
                    if (r["elemento"].ToString() != "SQDIP")
                    {
                        items += "<tr>"
                                    + "<td class='align-middle'>" + r["codigo"].ToString() + ".- " + r["disciplina"].ToString() + "</td>"
                                    + "<td class='font-weight-bold text-center align-middle text-" + r["class"].ToString() + "'>" + r["performance"].ToString() + "%</td>"
                                + "</tr>";
                    }
                }

                items += "</tbody></table></div></br>";

                items += "<input class='dropTableButton' type='button' id='drpdwnTbl_Bttn2' value='Ensamble Final &#9660' onclick='showhideTable(2)'/>"
                            + "<div class='dropTableDiv' id='tbl2' style='display: none'>"
                                + "<table class='table table-bordered' id='finalAssmblyTable' width='100%'>"
                                    + "<thead>"
                                        + "<tr class='tr-tipoOSA'>"
                                            //+ "<th class='text-center align-middle'>SPQVC</th>"
                                            + "<th class='text-center align-middle'>Disciplina</th>"
                                            + "<th class='text-center align-middle'>Performance</th>"
                                        + "</tr>"
                                    + "</thead>"
                                    + "<tbody>";

                foreach (DataRow r in dtItems.Rows)
                {
                    if (r["codigo"].ToString().Length > 2)
                    {
                        if (r["codigo"].ToString().Substring(0, 2) == "EF")
                        {
                            items += "<tr>"
                                        //+ "<td class='text-center align-middle'>" + r["elemento"].ToString() + "</td>"
                                        + "<td class='align-middle'>" + r["codigo"].ToString() + ".- " + r["disciplina"].ToString() + "</td>"
                                        + "<td class='font-weight-bold text-center align-middle text-" + r["class"].ToString() + "'>" + r["performance"].ToString() + "%</td>"
                                    + "</tr>";
                        }
                    }
                }

                items += "</tbody></table></div></br>";

                items += "<input class='dropTableButton' type='button' id='drpdwnTbl_Bttn3' value='Corte &#9660' onclick='showhideTable(3)'/>"
                            + "<div class='dropTableDiv' id='tbl3' style='display: none'>"
                                + "<table class='table table-bordered' id='cutTable' width='100%'>"
                                    + "<thead>"
                                        + "<tr class='tr-tipoOSA'>"
                                            //+ "<th class='text-center align-middle'>SPQVC</th>"
                                            + "<th class='text-center align-middle'>Disciplina</th>"
                                            + "<th class='text-center align-middle'>Performance</th>"
                                        + "</tr>"
                                    + "</thead>"
                                    + "<tbody>";

                foreach (DataRow r in dtItems.Rows)
                {
                    if (r["codigo"].ToString().Length > 2)
                    {
                        if (r["codigo"].ToString().Substring(0, 1) == "C")
                        {
                            items += "<tr>"
                                        //+ "<td class='text-center align-middle'>" + r["elemento"].ToString() + "</td>"
                                        + "<td class='align-middle'>" + r["codigo"].ToString() + ".- " + r["disciplina"].ToString() + "</td>"
                                        + "<td class='font-weight-bold text-center align-middle text-" + r["class"].ToString() + "'>" + r["performance"].ToString() + "%</td>"
                                    + "</tr>";
                        }
                    }
                }

                items += "</tbody></table></div></br>";

                items += "<input class='dropTableButton' type='button' id='drpdwnTbl_Bttn4' value='Lead Prep Secundario &#9660' onclick='showhideTable(4)'/>"
                            + "<div class='dropTableDiv' id='tbl4' style='display: none'>"
                                + "<table class='table table-bordered' id='leadTable' width='100%'>"
                                    + "<thead>"
                                        + "<tr class='tr-tipoOSA'>"
                                            //+ "<th class='text-center align-middle'>SPQVC</th>"
                                            + "<th class='text-center align-middle'>Disciplina</th>"
                                            + "<th class='text-center align-middle'>Performance</th>"
                                        + "</tr>"
                                    + "</thead>"
                                    + "<tbody>";

                foreach (DataRow r in dtItems.Rows)
                {
                    if (r["codigo"].ToString().Length > 2)
                    {
                        if (r["codigo"].ToString().Substring(0, 2) == "LP")
                        {
                            items += "<tr>"
                                        //+ "<td class='text-center align-middle'>" + r["elemento"].ToString() + "</td>"
                                        + "<td class='align-middle'>" + r["codigo"].ToString() + ".- " + r["disciplina"].ToString() + "</td>"
                                        + "<td class='font-weight-bold text-center align-middle text-" + r["class"].ToString() + "'>" + r["performance"].ToString() + "%</td>"
                                    + "</tr>";
                        }
                    }
                }

                items += "</tbody></table></div>";

                items += "<div>"
                            + "<button type='button' id='xlbttn' title='Export Summary Tables to Excel File' onclick='exportSummary()'>"
                                + "<img src = 'img/excel.png' width='32' height='32'/>"
                            + "</button>"
                            + "<iframe id='txtArea1' style='display: none'></iframe>"
                         + "</div>";

                items += "</div>";

                litItems.Text = items;
            }
        }        
    }

    public string FiltroMes()
    {
        string mes = "";

        switch(ddlMes.SelectedItem.Value)
        {
            case "E":
                mes = "AND DATEPART(MONTH, fh) = 1";
                break;
            case "F":
                mes = "AND DATEPART(MONTH, fh) = 2";
                break;
            case "Mz":
                mes = "AND DATEPART(MONTH, fh) = 3";
                break;
            case "Ab":
                mes = "AND DATEPART(MONTH, fh) = 4";
                break;
            case "My":
                mes = "AND DATEPART(MONTH, fh) = 5";
                break;
            case "Jn":
                mes = "AND DATEPART(MONTH, fh) = 6";
                break;
            case "Jl":
                mes = "AND DATEPART(MONTH, fh) = 7";
                break;
            case "Ag":
                mes = "AND DATEPART(MONTH, fh) = 8";
                break;
            case "S":
                mes = "AND DATEPART(MONTH, fh) = 9";
                break;
            case "O":
                mes = "AND DATEPART(MONTH, fh) = 10";
                break;
            case "N":
                mes = "AND DATEPART(MONTH, fh) = 11";
                break;
            case "D":
                mes = "AND DATEPART(MONTH, fh) = 12";
                break;
            default:
                mes = "";
                break;
        }

        return mes;
    }
	
	public string ObtenerColor(float porcentaje)
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