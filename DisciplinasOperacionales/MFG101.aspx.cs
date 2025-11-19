using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Globalization;

public partial class Reportes : System.Web.UI.Page
{
    public ConSQL sql, sqlDB05;
    public DataTable dtTotalAreas, dtTotalAsistencias, dtLineas, dtRespuestas;
    public string tablaTotalAreas = "", tablaTotalAsistencias = "", claseTotal = "", okW1 = "", okW2 = "", okW3 = "", okW4 = "", okW5 = "",
        linkHistorialW1 = "", linkHistorialW2 = "", linkHistorialW3 = "", linkHistorialW4 = "", linkHistorialW5 = "", tituloExcel = "Evaluacion Disciplinas Operacionales", tituloReportes = "Scorecard Plantas";
    public int year, mes;
    public string idPlanta;
    public static Dictionary <int,string> dictLineas = new Dictionary<int,string>();
    
    protected void Page_Load(object sender, EventArgs e)
    {
        Credenciales();

        sqlDB05 = new ConSQL(Env.getDB05ConnectionString("DTv2"));
        sql = new ConSQL(Env.getAppServerDbConnectionString("DisciplinasOperacionales"));

        if (!IsPostBack)
        {
            sql.llenaDropDownList(ddlPlanta, sql.selec("SELECT DISTINCT planta FROM [CatPlantas].[dbo].[Cat_Plantas] WHERE planta NOT IN ('RBE XXI','Vicente Guerrero','Guadalupe III Sat.','MECA','PMS')"), "planta", "planta");
            ddlPlanta.SelectedIndex = ddlPlanta.Items.IndexOf(ddlPlanta.Items.FindByValue(Session["Planta"].ToString()));
            ddlTurno.Items.Add("A");
            ddlTurno.Items.Add("B");
            ddlTurno.Items.Add("C");
            DateTime currentDate = DateTime.Now;
		    int year = currentDate.Year;
            System.Globalization.Calendar calendar = new System.Globalization.GregorianCalendar();
            int weekNumber = calendar.GetWeekOfYear(currentDate, CalendarWeekRule.FirstDay, DayOfWeek.Monday);
            string weekYear = year.ToString() + "-W" + weekNumber.ToString();
			txtMes.Text = weekYear;
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
            idPlanta = Session["idPlanta"].ToString();
        }catch(Exception ex){
      Response.Redirect(Env.redirectUrl);
        }
    }

    protected void btnMostrar_Click(object sender, EventArgs e)
    {
        if (txtMes.Text != "")
        {
            

            //Consulta Total de Areas
            dtLineas = sqlDB05.selec("SELECT id, Alias FROM Empaques.dbo.Codigos where hostname = 1 AND idPlanta = " + idPlanta + " ORDER BY Alias asc");
            foreach (DataRow r in dtLineas.Rows)
            {
                int id = -1;
				Int32.TryParse(r["id"].ToString(), out id);
                dictLineas.Add(id, r["Alias"].ToString());
            }
            DateTime Lunes = GetMondayFromWeek(txtMes.Text);

            dtRespuestas = sqlDB05.selec("SELECT DISTINCT idAlias, cast(fh as date) AS Fecha, count(id) AS Respuestas  FROM [DTv2].[dbo].[MFG1O1_Respuestas] where idplanta = " + idPlanta 
                                        + " AND cast(fh as date) >= '" + Lunes.ToString("yyyy-MM-dd") + "' AND cast(fh as date) <='" + Lunes.AddDays(4).ToString("yyyy-MM-dd") + "' "
                                        + " AND Turno = '" + ddlTurno.SelectedItem.ToString() + "' Group by idAlias, cast(fh as date) ORDER BY Fecha asc");


            tituloReportes = "Scorecard (" + ddlPlanta.SelectedItem.Text + ", " + ObtenerMes(Lunes.Month) + " " + Lunes.Year + ")";

            //Crea la tabla
            tablaTotalAreas += "<div class='col-sm-12 table-responsive'><table class='table' id='tablaReportes' width='100%'>"
                                + "<thead>"
                                    + "<tr class='tr-tipoOSA text-center' style='font-size: 13px;'>"
                                        + "<th></th>"
                                        + "<th></th>"
                                        + "<th>" + Lunes.ToString("yyyy-MM-dd") + "</th>"
                                        + "<th>" + Lunes.AddDays(1).ToString("yyyy-MM-dd") + "</th>"
                                        + "<th>" + Lunes.AddDays(2).ToString("yyyy-MM-dd") + "</th>"
                                        + "<th>" + Lunes.AddDays(3).ToString("yyyy-MM-dd") + "</th>"
                                        + "<th>" + Lunes.AddDays(4).ToString("yyyy-MM-dd") + "</th>"
                                        + "<th>Promedio Semana</th>"
                                    + "</tr>"
                                + "</thead>"
                                + "<tbody style='font-size: 12px;'>";

            if (dtRespuestas.Rows.Count > 0)
            {
                //Titulo del resultado por areas
                tablaTotalAreas += "<tr class='tr-elemento' style='font-size: 12px;'>"
                                        + "<td></td>"
                                        + "<td>Linea</td>"
                                        + "<td></td>"
                                        + "<td></td>"
                                        + "<td></td>"
                                        + "<td></td>"
                                        + "<td></td>"
                                        + "<td></td>"
                                    + "</tr>";

                
                List<string[]> Renglones = new List<string[]>();
                foreach (DataRow r in dtRespuestas.Rows)
                {

                    int resp = 0;
				    Int32.TryParse(r["Respuestas"].ToString(), out resp);
                    if (resp>15) {resp=15;}
                    int idAlias = -1;
				    Int32.TryParse(r["idAlias"].ToString(), out idAlias);
                    string Alias = "";
		            dictLineas.TryGetValue(idAlias, out Alias);

                    

                    string [] renglon = new string[6];
                    renglon[0] = Alias;      

                    if (r["Fecha"].ToString() == Lunes.AddDays(0).ToString("yyyy-MM-dd"))
                    {
                        renglon[1] = (resp / 15 * 100).ToString();
                    }
                    else if (r["Fecha"].ToString() == Lunes.AddDays(1).ToString("yyyy-MM-dd"))
                    {
                        renglon[2] = (resp / 15 * 100).ToString();
                    }
                    else if (r["Fecha"].ToString() == Lunes.AddDays(2).ToString("yyyy-MM-dd"))
                    {
                        renglon[3] = (resp / 15 * 100).ToString();
                    }
                    else if (r["Fecha"].ToString() == Lunes.AddDays(3).ToString("yyyy-MM-dd"))
                    {
                        renglon[4] = (resp / 15 * 100).ToString();
                    }
                    else if (r["Fecha"].ToString() == Lunes.AddDays(4).ToString("yyyy-MM-dd"))
                    {
                        renglon[5] = (resp / 15 * 100).ToString();
                    }
                    
                    tablaTotalAreas += "<tr>"
                                        + "<td></td>"
                                        + "<td class='" + claseTotal + "'>" + Alias + "</td>"
                                        + "<td style='font-size: 14px;' class='text-center font-weight-bold " + ObtenerColor(Convert.ToSingle(resp/15*100)) + "'>" + linkHistorialW1 + "</td>"
                                        + "<td style='font-size: 14px;' class='text-center font-weight-bold " + ObtenerColor(Convert.ToSingle(r["W2"].ToString())) + "'>" + linkHistorialW2 + "</td>"
                                        + "<td style='font-size: 14px;' class='text-center font-weight-bold " + ObtenerColor(Convert.ToSingle(r["W3"].ToString())) + "'>" + linkHistorialW3 + "</td>"
                                        + "<td style='font-size: 14px;' class='text-center font-weight-bold " + ObtenerColor(Convert.ToSingle(r["W4"].ToString())) + "'>" + linkHistorialW4 + "</td>"
                                        + "<td style='font-size: 14px;' class='text-center font-weight-bold " + ObtenerColor(Convert.ToSingle(r["W5"].ToString())) + "'>" + linkHistorialW5 + "</td>"
                                        + "<td style='font-size: 14px;' class='text-center font-weight-bold " + ObtenerColor(Convert.ToSingle(r["mes"].ToString())) + "'>" + r["mes"].ToString() + "%</td>"
                                    + "</tr>";
                }
            }

            //Row vacio como salto de linea
            /*tablaTotalAreas += "<tr>"
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
            }*/

            litReportes.Text = tablaTotalAreas +  "</tbody></table></div>";
            tituloExcel = "Evaluacion Disciplinas Operacionales " + ddlPlanta.SelectedItem.Text + " " + ObtenerMes(mes) + " " + year;
        }
    }
     // Obtener fecha de inicio de la semana
    public static DateTime GetMondayFromWeek(string week)
    {
        // Validar que el formato es correcto
        if (string.IsNullOrEmpty(week) || !week.Contains("-W"))
        {
            throw new ArgumentException("El formato debe ser 'YYYY-Www', por ejemplo: '2024-W48'.");
        }

        // Dividir el string para obtener el año y la semana
		week = week.Replace("W","");
        var parts = week.Split('-');
        int year = int.Parse(parts[0]);
        int weekNumber = int.Parse(parts[1]);

        // Crear el primer día del año
        DateTime jan1 = new DateTime(year, 1, 1);

        // Obtener el primer jueves del año (para calcular correctamente la primera semana)
        int daysOffset = DayOfWeek.Thursday - jan1.DayOfWeek;
        DateTime firstThursday = jan1.AddDays(daysOffset);

        // Obtener el primer lunes de la primera semana
        var firstMonday = firstThursday.AddDays(-3);

        // Calcular la fecha del lunes de la semana indicada
        var mondayOfWeek = firstMonday.AddDays((weekNumber - 1) * 7);

        return mondayOfWeek;
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