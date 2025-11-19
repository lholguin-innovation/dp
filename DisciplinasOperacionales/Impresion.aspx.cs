using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

public partial class Impresion : System.Web.UI.Page
{
    public ConSQL sql;
    public DataTable dtDisciplinas, dtAsistencia, dtResultados, dtPlanes;
    public string elemento = "", tablaDisciplinas = "", tablaResultado = "", tablaPlanes = "", periodo = "", realizo = "", fecha = "", ok = "", nok = "";
    public int mes, year;

    protected void Page_Load(object sender, EventArgs e)
    {
        sql = new ConSQL(Env.getAppServerDbConnectionString("DisciplinasOperacionales"));

        if (!IsPostBack)
        {
            mes = DateTime.Parse(Request["fecha"].ToString()).Month;
            year = DateTime.Parse(Request["fecha"].ToString()).Year;
            periodo = ObtenerMes(mes) + " " + year;
            fecha = sql.scalar("SELECT CONVERT(VARCHAR(11),CONVERT(DATETIME,'" + Request["fecha"].ToString() + "'))").ToString();

            //Consulta disciplinas con respuestas
            dtDisciplinas = sql.selec("SELECT E.codigo, D.elemento, D.disciplina, E.respuesta, E.usuario FROM (SELECT codigo, respuesta, usuario FROM [DisciplinasOperacionales].[dbo].[Evaluacion] WHERE llave = '" + Request["key"].ToString() + "') E "
                                    + "LEFT JOIN "
                                    + "(SELECT codigo, elemento, disciplina FROM [DisciplinasOperacionales].[dbo].[Disciplinas]) D "
                                    + "ON E.codigo = D.codigo");

            if (dtDisciplinas.Rows.Count > 0)
            {
                realizo = dtDisciplinas.Rows[0]["usuario"].ToString();

                tablaDisciplinas += "<div class='col-sm-9'>"
                                        + "<table width='100%'>"
                                            + "<thead>"
                                                + "<tr class='tr-tipoOSA text-center' style='font-size: 14px;'>"
                                                    + "<th>C&oacute;digo</th>"
                                                    + "<th>Disciplina</th>"
                                                    + "<th>OK</th>"
                                                    + "<th>NOK</th>"
                                                + "</tr>"
                                            + "</thead>"
                                            + "<tbody>";

                foreach (DataRow r in dtDisciplinas.Rows)
                {
                    //Si elemento es diferente de la temporal, agrega row como elemento
                    if (elemento != r["elemento"].ToString())
                    {
                        elemento = r["elemento"].ToString();

                        tablaDisciplinas += "<tr class='tr-elemento' style='font-size: 12px;'>"
                                            + "<td></td>"
                                            + "<td>" + elemento + "</td>"
                                            + "<td></td>"
                                            + "<td></td>"
                                        + "</tr>";
                    }

                    if (r["respuesta"].ToString() == "OK")
                    {
                        ok = "<i class='fa fa-check'></i>";
                    }
                    else
                    {
                        nok = "<i class='fa fa-times'></i>";
                    }

                    tablaDisciplinas += "<tr style='font-size: 12px;'>"
                                            + "<td>" + r["codigo"].ToString() + "</td>"
                                            + "<td>" + r["disciplina"].ToString() + "</td>"
                                            + "<td style='font-size: 16px;'>" + ok + "</td>"
                                            + "<td style='font-size: 16px;'>" + nok + "</td>"
                                        + "</tr>";

                    ok = ""; nok = "";
                }

                tablaDisciplinas += "</tbody></table></div>";
            }

            //Consulta asistencia
            dtAsistencia = sql.selec("SELECT S.dpto, S.nombre, CASE WHEN P.participante IS NOT NULL THEN 1 ELSE 0 END asistio FROM (SELECT dpto, nombre FROM [DisciplinasOperacionales].[dbo].[Staff] WHERE planta = '" + Request["planta_sel"].ToString() + "' AND nombre <> '' AND correo <> '') S "
                                    + "LEFT JOIN "
                                    + "(SELECT participante FROM [DisciplinasOperacionales].[dbo].[Asistencia] WHERE llave = '" + Request["key"].ToString() + "') P "
                                    + "ON S.dpto = P.participante");

            tablaDisciplinas += "<div class='col-sm-3'>"
                                    + "<table id='tablaAsistencia' width='100%'>"
                                        + "<thead>"
                                            + "<tr class='tr-tipoOSA text-center' style='font-size: 14px;'>"
                                                + "<th>Asistencia</th>"
                                                + "<th></th>"
                                            + "</tr>"
                                        + "</thead>"
                                        + "<tbody>";

            if (dtAsistencia.Rows.Count > 0)
            {
                foreach (DataRow r in dtAsistencia.Rows)
                {
                    if (r["asistio"].ToString() == "1")
                    {
                        ok = "<i class='fa fa-check'></i>";
                    }
                    else
                    {
                        ok = "<i class='fa fa-times'></i>";
                    }

                    tablaDisciplinas += "<tr style='font-size: 12px;'>"
                                            + "<td>" + r["nombre"].ToString() + "&nbsp;&nbsp;(" + r["dpto"].ToString() + ")</td>"
                                            + "<td style='font-size: 16px;'>" + ok + "</td>"
                                        + "</tr>";

                    ok = "";
                }
            }
            else
            {
                tablaDisciplinas += "<tr class='text-center' style='font-size: 14px;'>"
                                        + "<td>Sin personal asignado</td>"
                                        + "<td></td>"
                                    + "</tr>";
            }

            tablaDisciplinas += "</tbody></table></div>";

            litEvaluacion.Text = tablaDisciplinas;

            //Consulta resultados
            dtResultados = sql.selec("SELECT H.area, H.evaluacion, S.W1, S.W2, S.W3, S.W4, S.W5, S.mes FROM (SELECT area, evaluacion FROM [DisciplinasOperacionales].[dbo].[Historial] WHERE llave = '" + Request["key"].ToString() + "') H "
                                    + "LEFT JOIN "
                                    + "(SELECT * FROM [DisciplinasOperacionales].[dbo].[ScorecardAreas]('" + Request["planta_sel"].ToString() + "', " + mes + ", " + year + ") WHERE area = '" + Request["area"].ToString() + "') S "
                                    + "ON H.area = S.area");

            if (dtResultados.Rows.Count > 0)
            {
                tablaResultado += "<div class='col-sm-12'>"
                                        + "<div class='row'>"
                                            + "<div class='col-sm-3 text-center'>"
                                                + "<h5> Total </h5><br>"
                                                + "<h1 class='" + ObtenerColor(Convert.ToSingle(dtResultados.Rows[0]["evaluacion"].ToString())) + "'> " + dtResultados.Rows[0]["evaluacion"].ToString() + "% </h1>"
                                            + "</div>"
                                            + "<div class='col-sm-9 text-center'>"
                                                + "<h5> Historial del mes (" + periodo + ") </h5><br>"
                                                + "<table width='100%'>"
                                                    + "<thead>"
                                                        + "<tr class='tr-tipoOSA text-center' style='font-size: 13px;'>"
                                                            + "<th>&Aacute;rea</th>"
                                                            + "<th>W1</th>"
                                                            + "<th>W2</th>"
                                                            + "<th>W3</th>"
                                                            + "<th>W4</th>"
                                                            + "<th>W5</th>"
                                                            + "<th>Promedio Mes</th>"
                                                        + "</tr>"
                                                    + "</thead>"
                                                    + "<tbody>";

                foreach (DataRow r in dtResultados.Rows)
                {
                    tablaResultado += "<tr style='font-size: 17px;'>"
                                            + "<td>" + r["area"].ToString() + "</td>"
                                            + "<td class='" + ObtenerColor(Convert.ToSingle(r["W1"].ToString())) + "'>" + r["W1"].ToString() + "%</td>"
                                            + "<td class='" + ObtenerColor(Convert.ToSingle(r["W2"].ToString())) + "'>" + r["W2"].ToString() + "%</td>"
                                            + "<td class='" + ObtenerColor(Convert.ToSingle(r["W3"].ToString())) + "'>" + r["W3"].ToString() + "%</td>"
                                            + "<td class='" + ObtenerColor(Convert.ToSingle(r["W4"].ToString())) + "'>" + r["W4"].ToString() + "%</td>"
                                            + "<td class='" + ObtenerColor(Convert.ToSingle(r["W5"].ToString())) + "'>" + r["W5"].ToString() + "%</td>"
                                            + "<td class='" + ObtenerColor(Convert.ToSingle(r["mes"].ToString())) + "'>" + r["mes"].ToString() + "%</td>"
                                        + "</tr>";
                }

                tablaResultado += "</tbody></table></div></div></div>";
                litResultado.Text = tablaResultado;
            }

            //Consulta planes
            dtPlanes = sql.selec("SELECT P.codigo, D.disciplina, plan_accion, responsable, CONVERT(VARCHAR(11),CONVERT(DATETIME,fh_promesa)) fh_promesa, [status] FROM (SELECT codigo, plan_accion, responsable, fh_promesa, [status] FROM [DisciplinasOperacionales].[dbo].[Planes] WHERE llave = '" + Request["key"].ToString() + "') P "
                                + "LEFT JOIN "
                                + "(SELECT codigo, disciplina FROM[DisciplinasOperacionales].[dbo].[Disciplinas]) D "
                                + "ON P.codigo = D.codigo");

            if (dtPlanes.Rows.Count > 0)
            {
                tablaPlanes += "<div class='col-sm-12'>"
                                + "<div class='row'>"
                                    + "<div class='col-sm-12'>"
                                        + "<table width='100%'>"
                                            + "<thead>"
                                                + "<tr class='tr-tipoOSA' style='font-size: 13px;'>"
                                                    + "<th class='text-center'>C&oacute;digo</th>"
                                                    + "<th>Plan</th>"
                                                    + "<th class='text-center'>Responsable</th>"
                                                    + "<th class='text-center'>Fecha promesa</th>"
                                                    + "<th class='text-center'>Status</th>"
                                                + "</tr>"
                                            + "</thead>"
                                            + "<tbody>";

                foreach (DataRow r in dtPlanes.Rows)
                {
                    tablaPlanes += "<tr style='font-size: 12px;'>"
                                        + "<td width='10%' class='text-center'>" + r["codigo"].ToString() + "</td>"
                                        + "<td width='45%'>" + r["plan_accion"].ToString() + "</td>"
                                        + "<td width='25%' class='text-center'>" + r["responsable"].ToString() + "</td>"
                                        + "<td width='10%' class='text-center'>" + r["fh_promesa"].ToString() + "</td>"
                                        + "<td width='10%' class='text-center'>" + r["status"].ToString() + "</td>"
                                    + "</tr>";
                }

                tablaPlanes += "</tbody></table></div></div></div>";
                litPlanes.Text = tablaPlanes;
            }
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
            color = "text-orange";
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