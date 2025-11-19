using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Checklist : System.Web.UI.Page
{
    public ConSQL sql;
    public DataTable dtDisciplinas, dtStaff, dtScorecard;
    public string tablaDisciplinas = "",  area = "", elemento = "", llave = "", plan = "", fh_realizacion = "", fh_promesa = "", responsable = "", 
        w1 = "", w2 = "", w3 = "", w4 = "", w5 = "", totalmes = "", periodo = "", contenidoModal = "", extension, ruta;
    public int total_disciplinas = 0, inicio_id_disciplinas=0, semana, hayFecha, hayEvaluacion, hayActualizacion;
    public float puntosDisciplina = 0, puntosElemento = 0, valor = 0, pesoDisciplina = 0, pesoElemento = 0, evaluacionTotal;

	public DataTable dtDatosArea ;
	public bool debug=false;
    protected void Page_Load(object sender, EventArgs e)
    {
        Credenciales();
litDebug.Visible=debug;
        sql = new ConSQL(Env.getAppServerDbConnectionString("DisciplinasOperacionales"));

        //total_disciplinas = Convert.ToInt32(sql.scalar("SELECT COUNT(*) cant FROM [DisciplinasOperacionales].[dbo].[Disciplinas] WHERE departamento is NULL"));
		//inicio_id_disciplinas =Convert.ToInt32(sql.scalar("SELECT  min(cast(id as int)) id  FROM [DisciplinasOperacionales].[dbo].[Disciplinas] WHERE departamento is NULL"));

		dtDatosArea=sql.selec("SELECT area, departamento FROM [DisciplinasOperacionales].[dbo].[Areas] WHERE planta = '" + lblPlanta.Text + "' AND activo = 'True' ORDER BY area");
        periodo = ObtenerMes(DateTime.Now.Month) + " " + DateTime.Now.Year; 
litDebug.Text+="SELECT area, departamento FROM [DisciplinasOperacionales].[dbo].[Areas] WHERE planta = '" + lblPlanta.Text + "' AND activo = 'True' ORDER BY area"+"  </br>";
        if (!IsPostBack)
        {
            sql.llenaDropDownList(ddlArea, sql.selec("SELECT area FROM [DisciplinasOperacionales].[dbo].[Areas] WHERE planta = '" + lblPlanta.Text + "' AND activo = 'True' ORDER BY area"), "area", "area");
			
litDebug.Text+="SELECT area FROM [DisciplinasOperacionales].[dbo].[Areas] WHERE planta = '" + lblPlanta.Text + "' AND activo = 'True' ORDER BY area"+"  </br>";
			try
            {
                if (Request["area"].ToString() != null)
                {
               //     ddlArea.SelectedIndex = ddlArea.Items.IndexOf(ddlArea.Items.FindByValue(Request["area"].ToString()));
                   // ddlArea.SelectedIndex = ddlArea.Items.IndexOf(ddlArea.Items.FindByValue(Request["area"].ToString()));
					ddlArea.SelectedValue = Request["area"].ToString();
litDebug.Text+=Request["area"].ToString()+"  " +ddlArea.Items.FindByValue(Request["area"].ToString()) +  "  "  + ddlArea.Items.IndexOf(ddlArea.Items.FindByValue(Request["area"].ToString())) +"  </br>";
litDebug.Text+=Request["area"].ToString()+"  " +ddlArea.SelectedIndex + "  </br>";
litDebug.Text+=Request["area"].ToString()+"  " +ddlArea.SelectedValue + "  </br>";
                    fh_realizacion = sql.scalar("SELECT fh_agenda FROM [DisciplinasOperacionales].[dbo].[Agenda] WHERE id = " + Request["id"].ToString()).ToString();
litDebug.Text+="SELECT fh_agenda FROM [DisciplinasOperacionales].[dbo].[Agenda] WHERE id = " + Request["id"].ToString()+"  </br>";
//return;
  //                  btnRealizar_Click(sender, e);
                }
            }
            catch { }
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

    protected void btnRealizar_Click(object sender, EventArgs e)
    {
        //Si la planta tiene al menos 1 area
        if (ddlArea.Items.Count > 0)
        {
			
			total_disciplinas = Convert.ToInt32(sql.scalar("SELECT COUNT(*) cant FROM [DisciplinasOperacionales].[dbo].[Disciplinas] WHERE departamento is NULL"));
			inicio_id_disciplinas =Convert.ToInt32(sql.scalar("SELECT  min(cast(isnull(id, 0) as int)) id  FROM [DisciplinasOperacionales].[dbo].[Disciplinas] WHERE departamento is null"));
            //Consulta si existe fecha agendada para este mes
            hayFecha = Convert.ToInt32(sql.scalar("SELECT COUNT(*) cant FROM [DisciplinasOperacionales].[dbo].[Agenda] WHERE planta = '" + lblPlanta.Text + "' AND fh_agenda = CAST(GETDATE() as Date) AND [status] = 'Pendiente' AND area = '" + ddlArea.SelectedItem.Text + "'"));
            Response.Write("SELECT COUNT(*) cant FROM [DisciplinasOperacionales].[dbo].[Agenda] WHERE planta = '" + lblPlanta.Text + "' AND fh_agenda = CAST(GETDATE() as Date) AND [status] = 'Pendiente' AND area = '" + ddlArea.SelectedItem.Text + "'<br>");
            /*
                TBD en vez de revisar si hay evaluacion para esa fecha, creo que deberia revisar si se termino la evaluacion de la fecha agendada, si no, 
            */
            //Consulta si ya existe una evaluacion para este dia
            string strExisteEvaluacion="SELECT count(*) FROM [DisciplinasOperacionales].[dbo].[Agenda] a " +
                "JOIN [DisciplinasOperacionales].[dbo].[Historial] h ON a.llave = h.llave and a.planta= h.planta "+
                "WHERE a.id = "+ Request["id"];
            if(Request["id"] != null){
                hayEvaluacion = Convert.ToInt32(sql.scalar(strExisteEvaluacion));
                hayFecha = 1;
            }else{
                strExisteEvaluacion="SELECT count(*)  "+
                "FROM [DisciplinasOperacionales].[dbo].[Agenda] a "+
                "JOIN [DisciplinasOperacionales].[dbo].[Historial] h ON a.llave = h.llave and a.planta= h.planta "+
                "WHERE a.planta = '" + lblPlanta.Text + "'  AND a.area = '" + ddlArea.SelectedItem.Text + "' " +
                "AND fh_agenda = CONVERT(DATE,GETDATE())";
                /*
                "SELECT COUNT(*) cant FROM [DisciplinasOperacionales].[dbo].[Historial] "+
                "WHERE planta = '" + lblPlanta.Text + "' AND area = '" + ddlArea.SelectedItem.Text + "' AND fh = CONVERT(DATE,GETDATE())"
                */
                hayEvaluacion = Convert.ToInt32(sql.scalar(strExisteEvaluacion)); 
            }
 
            //Si hay fecha agendada
			litDebug.Visible=false;
			litDebug.Text="1<br>";
            if (hayFecha > 0)
            {
				litDebug.Text += "2<br>";
                //Si no hay una evaluacion
                if (hayEvaluacion == 0)
                {
					litDebug.Text+="3<br>";
                    //Consulta disciplinas
					/*
                    dtDisciplinas = sql.selec("SELECT id, A.codigo, elemento, disciplina, valor, archivo, ruta FROM [DisciplinasOperacionales].[dbo].[Disciplinas] A "
                                            + "LEFT JOIN "
                                            + "(SELECT codigo, archivo, ruta FROM [DisciplinasOperacionales].[dbo].[Contenido] WHERE planta = '" + lblPlanta.Text + "') B "
                                            + "ON A.codigo = B.codigo");
											*/
					DataRow drDepaArea = dtDatosArea.Select("area='" + ddlArea.SelectedItem.Text+"'" ).FirstOrDefault();
					string depaArea=drDepaArea["Departamento"].ToString();
					if(depaArea == "" || depaArea =="NULL")
						depaArea = " is NULL";
					else
						depaArea = " = '" + depaArea + "'";
					string sqlIdDisc = "SELECT ISNULL(MIN(CAST(id AS INT)), 1) AS id FROM [DisciplinasOperacionales].[dbo].[Disciplinas] WHERE departamento  " + depaArea + " or departamento = ''";
					total_disciplinas = Convert.ToInt32(sql.scalar("SELECT COUNT(*) cant FROM [DisciplinasOperacionales].[dbo].[Disciplinas] WHERE departamento "+depaArea + " or departamento = ''")); 
					litDebug.Visible=false;
					litDebug.Text += sqlIdDisc+  "<br>"; 
					
					inicio_id_disciplinas = Convert.ToInt32(sql.scalar(sqlIdDisc));
                    //Consulta disciplinas
					string strDic="SELECT id, A.codigo, elemento, disciplina, valor, archivo, ruta FROM [DisciplinasOperacionales].[dbo].[Disciplinas] A "
                                            + "LEFT JOIN "
                                            + "(SELECT codigo, archivo, ruta FROM [DisciplinasOperacionales].[dbo].[Contenido] WHERE planta = '" + lblPlanta.Text + "') B "
                                            + "ON A.codigo = B.codigo "
                                            + "WHERE A.Departamento "+ depaArea;
					litDebug.Text += strDic+"<br>";
					dtDisciplinas=sql.selec(strDic);

					litDebug.Text+="3.0<br>";
                    //Consulta STAFF
                    dtStaff = sql.selec("SELECT id, dpto, nombre, planta FROM [DisciplinasOperacionales].[dbo].[Staff] WHERE planta = '" + lblPlanta.Text + "' AND nombre <> '' AND nombre IS NOT NULL");

                    //Consulta resultados del area por el mes actual
                    dtScorecard = sql.selec("SELECT * FROM dbo.ScorecardAreas('" + lblPlanta.Text + "', DATEPART(MONTH,GETDATE()), DATEPART(YEAR,GETDATE())) WHERE area = '" + ddlArea.SelectedItem.Text + "'");

					litDebug.Text+="3.1<br>";
					if(dtDisciplinas == null)
						return;
					
                    if (dtDisciplinas.Rows.Count > 0)
                    {
						litDebug.Text+="3.2<br>";
                        puntosDisciplina = Convert.ToSingle(sql.scalar("SELECT SUM(valor) valor FROM [DisciplinasOperacionales].[dbo].[Disciplinas] WHERE Departamento =" + depaArea));
                        

                        //Crea encabezado
                        tablaDisciplinas = "<div class='row'>"
                                            + "<div class='col-sm-9'>"
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

                                puntosElemento = Convert.ToSingle(sql.scalar("SELECT valor FROM (SELECT elemento, SUM(valor) valor FROM [DisciplinasOperacionales].[dbo].[Disciplinas] WHERE elemento = '" + elemento + "' AND Departamento = " + depaArea + " GROUP BY elemento) T"));
                            }

                            valor = Convert.ToSingle(sql.scalar("SELECT valor FROM [DisciplinasOperacionales].[dbo].[Disciplinas] WHERE codigo = '" + r["codigo"].ToString() + "'"));

                            //Obtiene el peso porcentual de toda la disciplina
                            pesoDisciplina = (valor / puntosDisciplina) * 100;

                            //Obtiene el peso porcentual de un elemento
                            pesoElemento = (valor / puntosElemento) * 100;

                            if (r["archivo"].ToString() != "")
                            {
                                if (ObtenerExtension(r["archivo"].ToString()) == "ppt" || ObtenerExtension(r["archivo"].ToString()) == "pptx")
                                {
                                    ruta = "dinamico/" + Path.GetFileNameWithoutExtension(r["archivo"].ToString()) + ".pdf";
                                    extension = "pdf";
                                }
                                else if (ObtenerExtension(r["archivo"].ToString()) == "pdf")
                                {
                                    ruta = "dinamico/" + Path.GetFileNameWithoutExtension(r["archivo"].ToString()) + ".pdf";
                                    extension = "pdf";
                                }
                                else
                                {
                                    ruta = "dinamico/" + Path.GetFileName(r["archivo"].ToString());
                                    extension = Extencion(r["archivo"].ToString());
                                }

                                contenidoModal = "<i class='fa fa-info-circle' onclick='MostrarContenido(\"" + ruta + "\",\"" + extension + "\");'></i>";

                                extension = "";
                                ruta = "";
                            }

                            //Agrega row con pregunta y opciones
                            tablaDisciplinas += "<tr style='font-size: 12px;'>"
                                                + "<td>" + contenidoModal + "&nbsp;&nbsp;<input type='hidden' id='valor" + r["id"].ToString() + "' value='" + pesoElemento.ToString("#.#") + "' /><input type='hidden' id='elemento" + r["id"].ToString() + "' value='" + elemento + "' /><input type='hidden' id='codigo" + r["id"].ToString() + "' value='" + r["codigo"].ToString() + "' />" + r["codigo"].ToString() + "</td>"
                                                + "<td id='" + r["codigo"].ToString() + "'>" + r["disciplina"].ToString() + "</td>"
                                                + "<td><label><input type='radio' class='radio radio-success' name='" + r["id"].ToString() + "' id='OK" + r["id"].ToString() + "' value='OK' /><span></span></label></td>"
                                                + "<td><label><input type='radio' class='radio radio-danger' name='" + r["id"].ToString() + "' id='NOK" + r["id"].ToString() + "' value='NOK' /><span></span></label></td>"
                                            + "</tr>";

                            contenidoModal = "";
                        }

                        //Cierre de tabla
                        tablaDisciplinas += "</tbody></table></div>";

                        //Agrega lista de asistencia
                        tablaDisciplinas += "<div class='col-sm-3'>"
                                                + "<table class='table' id='tablaAsistencia' width='100%'>"
                                                    + "<thead>"
                                                        + "<tr class='tr-tipoOSA' style='font-size: 12px;'>"
                                                            + "<th>Asistencia</th>"
                                                            + "<th></th>"
                                                        + "</tr>"
                                                    + "</thead>"
                                                    + "<tbody>";

                        if (dtStaff.Rows.Count > 0)
                        {
                            foreach (DataRow r in dtStaff.Rows)
                            {
                                tablaDisciplinas += "<tr style='font-size: 12px;'>"
                                                        + "<td>" + r["nombre"].ToString() + "&nbsp;&nbsp;&nbsp;(" + r["dpto"].ToString() + ")</td>"
                                                        + "<td class='text-center'><label><input type='checkbox' class='checkbox' name='" + r["dpto"].ToString().Replace(" ", "") + "' id='" + r["dpto"].ToString().Replace(" ", "") + "' value='" + r["dpto"].ToString() + "' /><span></span></label></td>"
                                                    + "</tr>";
                            }
                        }
                        else
                        {
                            tablaDisciplinas += "<tr class='text-center' style='font-size: 14px;'>"
                                                    + "<td>Sin personal asignado <br> <a style='text-decoration: none;' href='Responsables.aspx?us=" + lblUsuario.Text + "&nombre=" + lblNombre.Text + "&p=" + lblPlanta.Text + "'>Asignar personal por &aacute;rea</a></td>"
                                                    + "<td></td>"
                                                + "</tr>";
                        }

                        //Cierre de tabla y divs
                        tablaDisciplinas += "</tbody></table></div></div>";

                        if (dtScorecard.Rows.Count > 0)
                        {
                            w1 = dtScorecard.Rows[0]["W1"].ToString();
                            w2 = dtScorecard.Rows[0]["W2"].ToString();
                            w3 = dtScorecard.Rows[0]["W3"].ToString();
                            w4 = dtScorecard.Rows[0]["W4"].ToString();
                            w5 = dtScorecard.Rows[0]["W5"].ToString();
                            totalmes = dtScorecard.Rows[0]["mes"].ToString();
                        }
                        else
                        {
                            w1 = "0";
                            w2 = "0";
                            w3 = "0";
                            w4 = "0";
                            w5 = "0";
                            totalmes = "0";
                        }

                        area = ddlArea.SelectedItem.Text;
                        litChecklist.Text = tablaDisciplinas;
                        btnValidar.Visible = true;
                    }
                    else
                    {
                        litChecklist.Text = "";
                        btnValidar.Visible = false;
                    }
                }
                else
                {
                    litMensaje.Text = "<script>swal('','Ya has relizado el checklist para esta área el dia de hoy.','warning');</script>";
                    btnValidar.Visible = false;
                    litChecklist.Text = "";
                }
            }
            else
            {
                try
                {
                    if (Request["area"].ToString() != null)
                    {
                        litMensaje.Text = "<script>swal({title: '', text: 'No puedes realizar esta evaluación por adelantado. Espera a la semana correspondiente para poder evaluar.',type: 'warning', confirmButtonClass: 'btn-success', confirmButtonText: 'OK', closeOnConfirm: false},function(){  window.location.href = 'Checklist.aspx?&us=" + lblUsuario.Text + "&nombre=" + lblNombre.Text + "&p=" + lblPlanta.Text + "'; });</script>";
                    }
                }
                catch (Exception x)
                {
                    litMensaje.Text = "<script>swal({ title: '', text: 'No existe fecha agendada para realizar esta evaluación.<br><br><a style=\"text-decoration: none;\" href=\"Calendario.aspx?us=" + lblUsuario.Text + "&nombre=" + lblNombre.Text + "&p=" + lblPlanta.Text + "\">Agendar una fecha para esta evaluación</a>', html: true, type: 'warning'});</script>";
                }

                btnValidar.Visible = false;
                litChecklist.Text = "";
            }
        }
        else
        {
            litMensaje.Text = "<script>swal({ title: '', text: 'No existen áreas registradas para esta planta.<br><br><a style=\"text-decoration: none;\" href=\"Areas.aspx?us=" + lblUsuario.Text + "&nombre=" + lblNombre.Text + "&p=" + lblPlanta.Text + "\">Agregar áreas</a>', html: true, type: 'warning'});</script>";
            btnValidar.Visible = false;
            litChecklist.Text = "";
        }
    }

    protected void btnEnviar_Click(object sender, EventArgs e)
    {
		litDebug.Visible=false;
        //Consulta disciplinas
        dtDisciplinas = sql.selec("SELECT id, codigo, elemento, disciplina, valor, Departamento FROM [DisciplinasOperacionales].[dbo].[Disciplinas]");
        //Consulta STAFF
        dtStaff = sql.selec("SELECT id, dpto, nombre, planta FROM [DisciplinasOperacionales].[dbo].[Staff] WHERE planta = '" + lblPlanta.Text + "' AND nombre <> '' AND nombre IS NOT NULL");

        //Genera llave
        llave = sql.scalar("SELECT dbo.fn_llave(10,'CN') AS llave").ToString();

        if (dtDisciplinas.Rows.Count > 0)
        {
            try
            {
                fh_realizacion = sql.scalar("SELECT fh_agenda FROM [DisciplinasOperacionales].[dbo].[Agenda] WHERE id = " + Request["id"].ToString()).ToString();
                semana = Convert.ToInt32(sql.scalar("SELECT CASE WHEN DATEPART(DAY,CONVERT(DATE,'" + fh_realizacion + "')) BETWEEN 1 AND 8 AND DATEPART(DAY, DATEDIFF(DAY, 0, CONVERT(DATE,'" + fh_realizacion + "'))/7 * 7)/7 + 1 = 5 THEN 1 ELSE DATEPART(DAY, DATEDIFF(DAY, 0, CONVERT(DATE,'" + fh_realizacion + "'))/7 * 7)/7 + 1 END semana"));
            }
            catch
            {
                fh_realizacion = sql.scalar("SELECT CONVERT(DATE,GETDATE())").ToString();
                semana = Convert.ToInt32(sql.scalar("SELECT CASE WHEN DATEPART(DAY,CONVERT(DATE,GETDATE())) BETWEEN 1 AND 8 AND DATEPART(DAY, DATEDIFF(DAY, 0, CONVERT(DATE,GETDATE()))/7 * 7)/7 + 1 = 5 THEN 1 ELSE DATEPART(DAY, DATEDIFF(DAY, 0, CONVERT(DATE,GETDATE()))/7 * 7)/7 + 1 END semana"));
            }
            //Response.Write("Fecha_Realizacion:                                           " + fh_realizacion + "<br>");

            foreach (DataRow r in dtStaff.Rows)
            {
                if (Request.Form[r["dpto"].ToString().Replace(" ", "")] != null)
                {
                    sql.exec("INSERT INTO [DisciplinasOperacionales].[dbo].[Asistencia] (participante, llave) VALUES ('" + Request.Form[r["dpto"].ToString().Replace(" ", "")] + "', '" + llave + "')");
                }
            }

            foreach (DataRow r in dtDisciplinas.Rows)
            {
                //ids para planes de accion
                plan = "plan" + r["codigo"].ToString();
                responsable = "responsable" + r["codigo"].ToString();
                fh_promesa = "fh_promesa" + r["codigo"].ToString();

                //Insertar planes de accion llenos o vacios
                if (Request.Form[plan] != null)
                {
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

                    if (Request.Form[fh_promesa].ToString() != "")
                    {
                        sql.exec("INSERT INTO [DisciplinasOperacionales].[dbo].[Planes] (codigo, plan_accion, responsable, fh_promesa, [status], usuario_registro, llave) VALUES ('" + r["codigo"].ToString() + "', " + plan + ", " + responsable + ", '" + Request.Form[fh_promesa] + "', 'Activo', '" + lblNombre.Text + "', '" + llave + "')");
                    }
                    else
                    {
                        sql.exec("INSERT INTO [DisciplinasOperacionales].[dbo].[Planes] (codigo, plan_accion, responsable, [status], usuario_registro, llave) VALUES ('" + r["codigo"].ToString() + "', " + plan + ", " + responsable + ", 'Activo', '" + lblNombre.Text + "', '" + llave + "')");
                    }
                }

                //Insertar disciplinas contestadas
                if (Request.Form[r["id"].ToString()] != null)
                {
					string sqlInsert ="INSERT INTO [DisciplinasOperacionales].[dbo].[Evaluacion] (area, codigo, respuesta, semana, fh, planta, usuario, llave) VALUES ('" + ddlArea.SelectedItem.Text + "', '" + r["codigo"].ToString() + "', '" + Request.Form[r["id"].ToString()] + "', " + semana + ", '" + fh_realizacion + "', '" + lblPlanta.Text + "', '" + lblNombre.Text + "', '" + llave + "')";
                    sql.exec(sqlInsert);
					litDebug.Text += sqlInsert+"<br>";
                }
            }

            evaluacionTotal = Convert.ToSingle(sql.scalar("SELECT [DisciplinasOperacionales].[dbo].[EvaluacionTotal]('" + llave + "')"));

			//Verifica si hay una actualizacion en esta semana
			hayActualizacion = Convert.ToInt32(sql.scalar("SELECT COUNT(*) cant FROM [DisciplinasOperacionales].[dbo].[Historial] WHERE planta = '" + lblPlanta.Text + "' AND area = '" + ddlArea.SelectedItem.Text + "' AND actualizacion = 'True' AND CONVERT(VARCHAR(7),fh,126) = CONVERT(VARCHAR(7),GETDATE(),126) AND semana = " + semana));
			
			if (hayActualizacion > 0)
			{
				sql.exec("DELETE FROM [DisciplinasOperacionales].[dbo].[Historial] WHERE planta = '" + lblPlanta.Text + "' AND area = '" + ddlArea.SelectedItem.Text + "' AND actualizacion = 'True' AND CONVERT(VARCHAR(7),fh,126) = CONVERT(VARCHAR(7),GETDATE(),126) AND semana = " + semana);
			}

            //Inserta evaluacion total en el historial
            sql.exec("INSERT INTO [DisciplinasOperacionales].[dbo].[Historial] (area, evaluacion, semana, actualizacion, fh, planta, usuario, llave) VALUES ('" + ddlArea.SelectedItem.Text + "', " + evaluacionTotal + ", " + semana + ", 'False', '" + fh_realizacion + "', '" + lblPlanta.Text + "', '" + lblNombre.Text + "', '" + llave + "')");
            //Response.Write("INSERT INTO [DisciplinasOperacionales].[dbo].[Historial] (area, evaluacion, semana, actualizacion, fh, planta, usuario, llave) VALUES ('" + ddlArea.SelectedItem.Text + "', " + evaluacionTotal + ", " + semana + ", 'False', '" + fh_realizacion + "', '" + lblPlanta.Text + "', '" + lblNombre.Text + "', '" + llave + "')");

            //Inserta en el log
            sql.exec("INSERT INTO [DisciplinasOperacionales].[dbo].[Log_Actualizaciones] (evaluacion, fh, llave) VALUES (" + evaluacionTotal + ", '" + fh_realizacion + "', '" + llave + "')");

            //Actualiza informacion de la agenda
            sql.exec("UPDATE [DisciplinasOperacionales].[dbo].[Agenda] SET [status] = 'Realizado', llave = '" + llave + "' FROM [DisciplinasOperacionales].[dbo].[Agenda] WHERE id = (SELECT TOP 1 id FROM [DisciplinasOperacionales].[dbo].[Agenda] WHERE planta = '" + lblPlanta.Text + "' AND area = '" + ddlArea.SelectedItem.Text + "' AND fh_agenda = CAST('" + fh_realizacion + "' AS Date) AND [status] = 'Pendiente' ORDER BY fh_agenda)");

            litChecklist.Text = "";
            btnValidar.Visible = false;
            litMensaje.Text = "<script>swal('','La evaluación se ha registrado correctamente.','success');</script>";
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

    public string Extencion(string archivo)
    {
        string ext = "";
        ext = archivo.Substring(archivo.LastIndexOf('.') + 1);
        return ext;
    }

    public string ObtenerExtension(string archivo)
    {
        string ext = "";
        ext = archivo.Substring(archivo.LastIndexOf('.') + 1);
        return ext;
    }
}