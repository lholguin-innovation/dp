using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

public partial class Historial : System.Web.UI.Page
{
    public ConSQL sql;
    public string llave, llave_nueva, tablaDisciplinas = "", tablaResultados = "", tablaPlanes = "", elemento = "", ok = "", nok = "", 
        periodo = "", plan = "", responsable = "", fh_promesa = "", status = "", planta, mesAct, mesAnt;
    public DataTable dtFechas, dtAreas, dtDisciplina, dtAsistencia, dtResultados, dtPlanes;
    public DateTime fh;
    public int mes, year, semanaAnt, semanaAct, hayAgendada;
    public float evaluacionAnterior, evaluacionActual;

    protected void Page_Load(object sender, EventArgs e)
    {
        Credenciales();

        sql = new ConSQL(Env.getAppServerDbConnectionString("DisciplinasOperacionales"));

        if (!IsPostBack)
        {
            sql.llenaDropDownList(ddlPlanta, sql.selec("SELECT DISTINCT planta FROM [CatPlantas].[dbo].[Cat_Plantas] WHERE planta NOT IN ('RBE XXI','Vicente Guerrero','Guadalupe III Sat.','PMS','MECA','RBE X')"), "planta", "planta");

            try
            {
                if (Request["p_sel"].ToString() != null)
                {
                    planta = Request["p_sel"].ToString();
                }
            }
            catch (Exception x)
            {
                planta = lblPlanta.Text; 
            }

            ddlPlanta.SelectedIndex = ddlPlanta.Items.IndexOf(ddlPlanta.Items.FindByValue(planta));
            ddlPlanta_SelectedIndexChanged(sender, e);
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

    protected void ddlPlanta_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (ddlPlanta.SelectedItem.Text != "")
        {
            litEvaluacion.Text = "";
            litResultados.Text = "";
            litPlanes.Text = "";

            dtAreas = sql.selec("SELECT DISTINCT area FROM [DisciplinasOperacionales].[dbo].[Historial] WHERE planta = '" + ddlPlanta.SelectedItem.Text + "' AND actualizacion = 'False'");

            if (dtAreas.Rows.Count > 0)
            {
                ddlArea.Items.Clear();
                txtMes.Text = "";
                ddlSemana.Items.Clear();

                sql.llenaDropDownList(ddlArea, sql.selec("SELECT DISTINCT area FROM [DisciplinasOperacionales].[dbo].[Historial] WHERE planta = '" + ddlPlanta.SelectedItem.Text + "' AND actualizacion = 'False'"), "area", "area");

                try
                {
                    if (Request["area"].ToString() != null)
                    {
                        ddlArea.SelectedIndex = ddlArea.Items.IndexOf(ddlArea.Items.FindByValue(Request["area"].ToString()));
                        fh = DateTime.Parse(Request["year"].ToString() + "-" + Request["mes"].ToString());
                        txtMes.Text = fh.ToString("yyyy-MM");
                        txtMes_TextChanged(sender, e);
                    }
                }
                catch
                {
                    txtMes.Text = DateTime.Now.ToString("yyyy-MM");
                    txtMes_TextChanged(sender, e);
                }
            }
            else
            {
                ddlArea.Items.Clear();
                txtMes.Text = "";
                ddlSemana.Items.Clear();
                btnActualizar.Visible = false;
                btnImprimir.Visible = false;
            }
        }
        else
        {
            litEvaluacion.Text = "";
            litResultados.Text = "";
            litPlanes.Text = "";
            btnActualizar.Visible = false;
            btnImprimir.Visible = false;
        }
    }

    protected void txtMes_TextChanged(object sender, EventArgs e)
    {
        if (ddlArea.Items.Count > 0 && ddlArea.SelectedItem.Text != "" && txtMes.Text != "")
        {
            litEvaluacion.Text = "";
            litResultados.Text = "";
            litPlanes.Text = "";

            try
            {
                if (Request["p_sel"].ToString() != null)
                {
                    planta = Request["p_sel"].ToString();
                }
            }
            catch (Exception x)
            {
                planta = ddlPlanta.SelectedItem.Text;
            }

            mes = Convert.ToInt32(DateTime.Parse(txtMes.Text).Month);
            year = Convert.ToInt32(DateTime.Parse(txtMes.Text).Year);

            dtFechas = sql.selec("SELECT DISTINCT 'W' + CONVERT(VARCHAR(1),semana) + ' (' + CONVERT(VARCHAR(11),CONVERT(DATETIME,fh)) + ')' fecha, semana FROM [DisciplinasOperacionales].[dbo].[Evaluacion] WHERE planta = '" + planta + "' AND area = '" + ddlArea.SelectedItem.Text + "' AND DATEPART(MONTH,fh) = " + mes + " AND DATEPART(YEAR,fh) = " + year);
            //Response.Write("SELECT DISTINCT 'W' + CONVERT(VARCHAR(1),semana) + ' (' + CONVERT(VARCHAR(11),CONVERT(DATETIME,fh)) + ')' fecha, semana FROM [DisciplinasOperacionales].[dbo].[Evaluacion] WHERE planta = '" + planta + "' AND area = '" + ddlArea.SelectedItem.Text + "' AND DATEPART(MONTH,fh) = " + mes + " AND DATEPART(YEAR,fh) = " + year);
            if (dtFechas.Rows.Count > 0)
            {
                sql.llenaDropDownList(ddlSemana, sql.selec("SELECT DISTINCT 'W' + CONVERT(VARCHAR(2),semana) + ' (' + CONVERT(VARCHAR(11),CONVERT(DATETIME,fh)) + ')' descripcion, CONVERT(VARCHAR, fh) fh FROM [DisciplinasOperacionales].[dbo].[Evaluacion] WHERE planta = '" + planta + "' AND area = '" + ddlArea.SelectedItem.Text + "' AND DATEPART(MONTH,fh) = " + mes + " AND DATEPART(YEAR,fh) = " + year), "fh", "descripcion");

                if (ddlSemana.Items.Count > 1)
                {
                    try
                    {
                        if (Request["fecha"].ToString() != null && !IsPostBack)
                        {
                            ddlSemana.SelectedIndex = ddlSemana.Items.IndexOf(ddlSemana.Items.FindByValue(Request["fecha"].ToString()));
                            btnBuscar_Click(sender, e);
                        }
                    }
                    catch { }
                }
                else
                {
                    btnBuscar_Click(sender, e);
                }
            }
            else
            {
                ddlSemana.Items.Clear();
                btnActualizar.Visible = false;
                btnImprimir.Visible = false;
            }
        }
        else
        {
            litEvaluacion.Text = "";
            litResultados.Text = "";
            litPlanes.Text = "";
            btnActualizar.Visible = false;
            btnImprimir.Visible = false;
        }
    }

    protected void btnBuscar_Click(object sender, EventArgs e)
    {
        if (ddlPlanta.SelectedItem.Text != "" && ddlArea.Items.Count > 0 && ddlArea.SelectedItem.Text != "" && txtMes.Text != "" && ddlSemana.Items.Count > 0 && ddlSemana.SelectedItem.Text != "")
        {
            //Consulta llave
            llave = sql.scalar("SELECT TOP 1 llave FROM [DisciplinasOperacionales].[dbo].[Historial] WHERE planta = '" + ddlPlanta.SelectedItem.Text + "' AND area = '" + ddlArea.SelectedItem.Text + "' AND fh = '" + ddlSemana.SelectedItem.Value + "' AND actualizacion = 'False'").ToString();

            mes = Convert.ToInt32(DateTime.Parse(txtMes.Text).Month);
            year = Convert.ToInt32(DateTime.Parse(txtMes.Text).Year);
            periodo = ObtenerMes(mes) + " " + year;

            litEvaluacion.Text = "";
            litResultados.Text = "";
            litPlanes.Text = "";

            if (llave != "")
            {
                //Consulta disciplinas con respuestas
                dtDisciplina = sql.selec("SELECT CASE WHEN elemento = 'Seguridad' THEN 1 WHEN elemento = 'Gente' THEN 2 WHEN elemento = 'Calidad' THEN 3 WHEN elemento = 'Volumen' THEN 4 WHEN elemento = 'Costo' THEN 5 END id, E.codigo, D.elemento, D.disciplina, E.respuesta FROM (SELECT DISTINCT codigo, respuesta FROM [DisciplinasOperacionales].[dbo].[Evaluacion] WHERE llave = '" + llave + "') E "
                                        + "LEFT JOIN "
                                        + "(SELECT codigo, elemento, disciplina FROM [DisciplinasOperacionales].[dbo].[Disciplinas]) D "
                                        + "ON E.codigo = D.codigo ORDER BY id");

                if (dtDisciplina.Rows.Count > 0)
                {
                    tablaDisciplinas += "<div class='col-sm-9'>"
                                        + "<table class='table' id='tablaDisciplinas' width='100%'>"
                                            + "<thead>"
                                                + "<tr class='tr-tipoOSA text-center' style='font-size: 12px;'>"
                                                    + "<th>C&oacute;digo</th>"
                                                    + "<th>Disciplina</th>"
                                                    + "<th>OK</th>"
                                                    + "<th>NOK</th>"
                                                + "</tr>"
                                            + "</thead>"
                                            + "<tbody>";

                    foreach (DataRow r in dtDisciplina.Rows)
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
                                                + "<td class='text-center' style='font-size: 16px;'>" + ok + "</td>"
                                                + "<td class='text-center' style='font-size: 16px;'>" + nok + "</td>"
                                            + "</tr>";

                        ok = ""; nok = "";
                    }

                    tablaDisciplinas += "</tbody></table></div>";
                }

                //Consulta asistencia
                dtAsistencia = sql.selec("SELECT S.dpto, S.nombre, CASE WHEN P.participante IS NOT NULL THEN 1 ELSE 0 END asistio FROM (SELECT dpto, nombre FROM [DisciplinasOperacionales].[dbo].[Staff] WHERE planta = '" + ddlPlanta.SelectedItem.Text + "' AND nombre <> '') S "
                                        + "LEFT JOIN "
                                        + "(SELECT participante FROM [DisciplinasOperacionales].[dbo].[Asistencia] WHERE llave = '" + llave + "') P "
                                        + "ON S.dpto = P.participante");

                tablaDisciplinas += "<div class='col-sm-3'>"
                                        + "<table class='table' id='tablaAsistencia' width='100%'>"
                                            + "<thead>"
                                                + "<tr class='tr-tipoOSA text-center' style='font-size: 12px;'>"
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
                                                + "<td>" + r["nombre"].ToString() + "&nbsp;&nbsp;&nbsp;(" + r["dpto"].ToString() + ")</td>"
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
                dtResultados = sql.selec("SELECT DISTINCT H.area, H.evaluacion, S.W1, S.W2, S.W3, S.W4, S.W5, S.mes FROM (SELECT area, evaluacion FROM [DisciplinasOperacionales].[dbo].[Historial] WHERE planta = '" + ddlPlanta.SelectedItem.Text + "' AND area = '" + ddlArea.SelectedItem.Text + "' AND fh = '" + ddlSemana.SelectedItem.Value + "') H "
                                        + "LEFT JOIN "
                                        + "(SELECT DISTINCT * FROM [DisciplinasOperacionales].[dbo].[ScorecardAreas]('" + ddlPlanta.SelectedItem.Text + "', " + mes + ", " + year + ") WHERE area = '" + ddlArea.SelectedItem.Text + "') S "
                                        + "ON H.area = S.area");
                /*Response.Write("SELECT DISTINCT H.area, H.evaluacion, S.W1, S.W2, S.W3, S.W4, S.W5, S.mes FROM (SELECT area, evaluacion FROM [DisciplinasOperacionales].[dbo].[Historial] WHERE planta = '" + ddlPlanta.SelectedItem.Text + "' AND area = '" + ddlArea.SelectedItem.Text + "' AND fh = '" + ddlSemana.SelectedItem.Value + "') H "
                                        + "LEFT JOIN "
                                        + "(SELECT DISTINCT * FROM [DisciplinasOperacionales].[dbo].[ScorecardAreas]('" + ddlPlanta.SelectedItem.Text + "', " + mes + ", " + year + ") WHERE area = '" + ddlArea.SelectedItem.Text + "') S "
                                        + "ON H.area = S.area");*/

                if (dtResultados.Rows.Count > 0)
                {
                    tablaResultados += "<div class='col-sm-12'>"
                                        + "<div class='title-block'>"
                                            + "<h2 class='title'> Resultados </h2>"
                                        + "</div><br>"
                                        + "<div class='row'>"
                                            + "<div class='col-sm-3 text-center'>"
                                                + "<h5> Total </h5><br>"
                                                + "<h1 class='" + ObtenerColor(Convert.ToSingle(dtResultados.Rows[0]["evaluacion"].ToString())) + "'> " + dtResultados.Rows[0]["evaluacion"].ToString() + "% </h1>"
                                            + "</div>"
                                            + "<div class='col-sm-9 text-center'>"
                                                + "<h5> Historial del mes (" + periodo + ") </h5>"
                                                + "<table class='table' id='tablaResultados' width='100%'>"
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
                        tablaResultados += "<tr style='font-size: 17px;'>"
                                                + "<td>" + r["area"].ToString() + "</td>"
                                                + "<td class='" + ObtenerColor(Convert.ToSingle(r["W1"].ToString())) + "'>" + r["W1"].ToString() + "%</td>"
                                                + "<td class='" + ObtenerColor(Convert.ToSingle(r["W2"].ToString())) + "'>" + r["W2"].ToString() + "%</td>"
                                                + "<td class='" + ObtenerColor(Convert.ToSingle(r["W3"].ToString())) + "'>" + r["W3"].ToString() + "%</td>"
                                                + "<td class='" + ObtenerColor(Convert.ToSingle(r["W4"].ToString())) + "'>" + r["W4"].ToString() + "%</td>"
                                                + "<td class='" + ObtenerColor(Convert.ToSingle(r["W5"].ToString())) + "'>" + r["W5"].ToString() + "%</td>"
                                                + "<td class='" + ObtenerColor(Convert.ToSingle(r["mes"].ToString())) + "'>" + r["mes"].ToString() + "%</td>"
                                            + "</tr>";
                    }

                    tablaResultados += "</tbody></table></div></div></div>";
                    litResultados.Text = tablaResultados;
                }

                //Consulta planes
                dtPlanes = sql.selec("SELECT P.codigo, D.disciplina, plan_accion, responsable, fh_promesa, [status] FROM (SELECT codigo, plan_accion, responsable, fh_promesa, [status] FROM [DisciplinasOperacionales].[dbo].[Planes] WHERE llave = '" + llave + "') P "
                                    + "LEFT JOIN "
                                    + "(SELECT codigo, disciplina FROM[DisciplinasOperacionales].[dbo].[Disciplinas]) D "
                                    + "ON P.codigo = D.codigo");

                if (dtPlanes.Rows.Count > 0)
                {
                    tablaPlanes += "<div class='col-sm-12'>"
                                        + "<div class='title-block'>"
                                            + "<h2 class='title'> Planes de acci&oacute;n </h2>"
                                        + "</div>"
                                        + "<div class='row'>"
                                            + "<div class='col-sm-12'>"
                                                + "<table class='table' id='tablaPlanes' width='100%'>"
                                                    + "<thead>"
                                                        + "<tr class='tr-tipoOSA text-center' style='font-size: 13px;'>"
                                                            + "<th>C&oacute;digo</th>"
                                                            + "<th>Disciplina</th>"
                                                            + "<th>Plan</th>"
                                                            + "<th>Responsable</th>"
                                                            + "<th>Fecha promesa</th>"
                                                            + "<th>Status</th>"
                                                        + "</tr>"
                                                    + "</thead>"
                                                    + "<tbody>";

                    foreach (DataRow r in dtPlanes.Rows)
                    {
                        if (r["plan_accion"].ToString() != "")
                        {
                            plan = "<input aria-multiline='true' type='text' style='font-size: 12px;' class='form-control' id='plan" + r["codigo"].ToString() + "' name='plan" + r["codigo"].ToString() + "' value='" + r["plan_accion"].ToString() + "' />";
                        }
                        else
                        {
                            plan = "<input aria-multiline='true' type='text' style='font-size: 12px;' class='form-control' id='plan" + r["codigo"].ToString() + "' name='plan" + r["codigo"].ToString() + "' />";
                        }

                        if (r["responsable"].ToString() != "")
                        {
                            responsable = "<input type='text' style='font-size: 12px;' class='form-control' id='responsable" + r["codigo"].ToString() + "' name='responsable" + r["codigo"].ToString() + "' value='" + r["responsable"].ToString() + "' />";
                        }
                        else
                        {
                            responsable = "<input type='text' style='font-size: 12px;' class='form-control' id='responsable" + r["codigo"].ToString() + "' name='responsable" + r["codigo"].ToString() + "' />";
                        }

                        if (r["fh_promesa"].ToString() != "")
                        {
                            fh = DateTime.Parse(r["fh_promesa"].ToString());
                            fh_promesa = "<input type='date' style='font-size: 12px;' class='form-control' id='fecha" + r["codigo"].ToString() + "' name='fecha" + r["codigo"].ToString() + "' value='" + fh.ToString("yyyy-MM-dd") + "' />";
                        }
                        else
                        {
                            fh_promesa = "<input type='date' style='font-size: 12px;' class='form-control' id='fecha" + r["codigo"].ToString() + "' name='fecha" + r["codigo"].ToString() + "' />";
                        }

                        if (r["status"].ToString() == "Activo")
                        {
                            status = "<select style='font-size: 12px;' name='status" + r["codigo"].ToString() + "' id='status" + r["codigo"].ToString() + "' class='form-control' ><option value='Activo'>Activo</option><option value='Cerrado'>Cerrado</option></select>";
                        }
                        else
                        {
                            status = "<select style='font-size: 12px;' name='status" + r["codigo"].ToString() + "' id='status" + r["codigo"].ToString() + "' class='form-control' ><option value='Cerrado'>Cerrado</option><option value='Activo'>Activo</option></select>";
                        }

                        tablaPlanes += "<tr style='font-size: 12px;'>"
                                            + "<td class='text-center'>" + r["codigo"].ToString() + "</td>"
                                            + "<td>" + r["disciplina"].ToString() + "</td>"
                                            + "<td>" + plan + "</td>"
                                            + "<td>" + responsable + "</td>"
                                            + "<td>" + fh_promesa + "</td>"
                                            + "<td>" + status + "</td>"
                                        + "</tr>";
                    }

                    tablaPlanes += "</tbody></table></div></div></div>";
                    litPlanes.Text = tablaPlanes;
                    btnActualizar.Visible = true;
                }
                else
                {
                    litPlanes.Text = "";
                    btnActualizar.Visible = false;
                }

                btnImprimir.Attributes.Remove("onclick");
                btnImprimir.Attributes.Add("onclick", "ImprimirDisciplinas('Impresion.aspx?us=" + lblUsuario.Text + "&nombre=" + lblNombre.Text + "&key=" + llave + "&planta_sel=" + ddlPlanta.SelectedItem.Text + "&planta_us=" + lblPlanta.Text + "&area=" + ddlArea.SelectedItem.Text + "&fecha=" + ddlSemana.SelectedItem.Value + "');");
                btnImprimir.Visible = true;
            }
        }
    }

    protected void btnActualizar_Click(object sender, EventArgs e)
    {
        //Consulta llave
        llave = sql.scalar("SELECT llave FROM [DisciplinasOperacionales].[dbo].[Historial] WHERE planta = '" + ddlPlanta.SelectedItem.Text + "' AND area = '" + ddlArea.SelectedItem.Text + "' AND fh = '" + ddlSemana.SelectedItem.Value + "'").ToString();

        //Consulta planes
        dtPlanes = sql.selec("SELECT P.codigo, D.disciplina, plan_accion, responsable, fh_promesa, [status] FROM (SELECT codigo, plan_accion, responsable, fh_promesa, [status] FROM [DisciplinasOperacionales].[dbo].[Planes] WHERE llave = '" + llave + "') P "
                            + "LEFT JOIN "
                            + "(SELECT codigo, disciplina FROM [DisciplinasOperacionales].[dbo].[Disciplinas]) D "
                            + "ON P.codigo = D.codigo");

        foreach (DataRow r in dtPlanes.Rows)
        {
            plan = "plan" + r["codigo"].ToString();
            responsable = "responsable" + r["codigo"].ToString();
            fh_promesa = "fecha" + r["codigo"].ToString();
            status = "status" + r["codigo"].ToString();

            if (Request.Form[plan] != "")
            {
                plan = "'" + Request.Form[plan] + "'";
            }
            else
            {
                plan = "NULL";
            }
            if (Request.Form[responsable] != "")
            {
                responsable = "'" + Request.Form[responsable] + "'";
            }
            else
            {
                responsable = "NULL";
            }
            if (Request.Form[fh_promesa] != "")
            {
                fh_promesa = "'" + Request.Form[fh_promesa] + "'";
            }
            else
            {
                fh_promesa = "NULL";
            }

            sql.exec("UPDATE [DisciplinasOperacionales].[dbo].[Planes] SET plan_accion = " + plan + ", responsable = " + responsable + ", fh_promesa = " + fh_promesa + ", [status] = '" + Request.Form[status] + "', usuario_mod = '" + lblNombre.Text + "', fh_mod = GETDATE() WHERE codigo = '" + r["codigo"].ToString() + "' AND llave = '" + llave + "'");
        }
        
		/*
        //Consulta resultado anterior
        evaluacionAnterior = Convert.ToSingle(sql.scalar("SELECT evaluacion FROM [DisciplinasOperacionales].[dbo].[Historial] WHERE llave = '" + llave + "'"));

        //Realiza un recalculo del resultado final tomando en cuenta planes de accion cerrados
        evaluacionActual = Convert.ToSingle(sql.scalar("SELECT [DisciplinasOperacionales].[dbo].[EvaluacionTotal]('" + llave + "')"));

        //Si son diferentes
        if (evaluacionActual != evaluacionAnterior)
        {
            //Consulta mes, semana anterior y actual
            mesAct = sql.scalar("SELECT CONVERT(VARCHAR(7), GETDATE(), 126) mes").ToString();
            mesAnt = sql.scalar("SELECT CONVERT(VARCHAR(7), fh, 126) mes FROM [DisciplinasOperacionales].[dbo].[Historial] WHERE llave = '" + llave + "'").ToString();
            semanaAct = Convert.ToInt32(sql.scalar("SELECT CASE WHEN DATEPART(DAY,CONVERT(DATE,GETDATE())) BETWEEN 1 AND 8 AND DATEPART(DAY, DATEDIFF(DAY, 0, CONVERT(DATE,GETDATE()))/7 * 7)/7 + 1 = 5 THEN 1 ELSE DATEPART(DAY, DATEDIFF(DAY, 0, CONVERT(DATE,GETDATE()))/7 * 7)/7 + 1 END semana"));
            semanaAnt = Convert.ToInt32(sql.scalar("SELECT semana FROM [DisciplinasOperacionales].[dbo].[Historial] WHERE llave = '" + llave + "'"));

            //Si se actualiza en la misma semana, actualiza el resultado, si no, agrega el resultado a la proxima semana
            if ((mesAct == mesAnt) && (semanaAct == semanaAnt))
            {
                sql.exec("UPDATE [DisciplinasOperacionales].[dbo].[Historial] SET evaluacion = " + evaluacionActual + " WHERE llave = '" + llave + "'");
				sql.exec("INSERT INTO [DisciplinasOperacionales].[dbo].[Log_Actualizaciones] (evaluacion, fh, llave) VALUES (" + evaluacionActual + ", CONVERT(DATE,GETDATE()), '" + llave + "')");
            }
            else
            {
				if ((mesAct == mesAnt) && (semanaAct > semanaAnt))
				{
					//Checa si hay una evaluacion agendada para proximos dias durante el mes
					hayAgendada = Convert.ToInt32(sql.scalar("SELECT COUNT(*) cant FROM [DisciplinasOperacionales].[dbo].[Agenda] WHERE planta = '" + ddlPlanta.SelectedItem.Text + "' AND area = '" + ddlArea.SelectedItem.Text + "' AND CONVERT(VARCHAR(7), fh_agenda, 126) = CONVERT(VARCHAR(7), GETDATE(), 126) AND [status] = 'Realizado' AND llave IS NOT NULL AND semana >= DATEPART(WEEK,GETDATE())"));

					if (hayAgendada == 0)
					{
						llave_nueva = sql.scalar("SELECT dbo.fn_llave(10,'CN') AS llave").ToString();
						
						//Agrega un resultado nuevo para esta semana
						sql.exec("INSERT INTO [DisciplinasOperacionales].[dbo].[Historial] (area, evaluacion, semana, actualizacion, fh, planta, usuario, llave) SELECT area, " + evaluacionActual + ", " + semanaAct + ", 'True', CONVERT(DATE,GETDATE()), planta, '" + lblNombre.Text + "', '" + llave_nueva + "' FROM [DisciplinasOperacionales].[dbo].[Historial] WHERE llave = '" + llave + "'");
						sql.exec("INSERT INTO [DisciplinasOperacionales].[dbo].[Log_Actualizaciones] (evaluacion, fh, llave) VALUES (" + evaluacionActual + ", CONVERT(DATE,GETDATE()), '" + llave_nueva + "')");
					}					
				}
            }
        }*/

        litMensaje.Text = "<script>swal({title: '', text: 'Se han actualizado los planes de acción correctamente.',type: 'success', confirmButtonClass: 'btn-success', confirmButtonText: 'OK', closeOnConfirm: false},function(){ $('#btnBuscar').trigger('click'); });</script>";
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

    protected void ddlArea_SelectedIndexChanged(object sender, EventArgs e)
    {
        txtMes.Text = "";
        ddlSemana.Items.Clear();
        litEvaluacion.Text = "";
        litResultados.Text = "";
        litPlanes.Text = "";
        btnActualizar.Visible = false;
    }
}