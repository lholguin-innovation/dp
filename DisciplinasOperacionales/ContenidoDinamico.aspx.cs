using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.IO;
using Syncfusion.Pdf;
using Syncfusion.Presentation;
using Syncfusion.PresentationToPdfConverter;
using System.Drawing;

public partial class ContenidoDinamico : System.Web.UI.Page
{
    public ConSQL sql;
    public DataTable dtContenido, dtDepArea;
    public string tablaContenido = "", inputArchivo = "", codigo = "", fh = "", nombre_archivo = "", server;
    public string[] datos;
    IPresentation powerpoint;
    PdfDocument pdf;


    protected void Page_Load(object sender, EventArgs e)
    {
        Credenciales();

        sql = new ConSQL(Env.getAppServerDbConnectionString("DisciplinasOperacionales"));
	dtDepArea=sql.selec("SELECT area, departamento FROM [DisciplinasOperacionales].[dbo].[Areas] WHERE planta = '" + lblPlanta.Text + "' AND activo = 'True' ORDER BY area");

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

protected void btnRealizar_Click(object sender, EventArgs e)
    {
MostrarContenidoDinamico();
}

    public void MostrarContenidoDinamico()
    {
	//DataRow depArea = New DataRow();
/*
	DataRow depArea = dtDepArea.Select("area = '" + ddlArea.SelectedValue + "'").First();
	string cond="";
	if(depArea != null){
		cond=" in ('"+depArea["Departamento"]+"')";
	}else{
		cond="is null";
	}
*/
	DataRow[] depArea = dtDepArea.Select("area = '" + ddlArea.SelectedValue + "'");
	string cond=""; 
	if(depArea.Count()==1){ 
		if(depArea[0]["Departamento"].ToString() != "NULL"){
			cond=" in ('"+depArea[0]["Departamento"]+"')";
		}else{ 
			cond=" is null";
		}
	}else{
		cond="is null"; 
	} 
	string qryContenido="SELECT C.codigo, elemento, disciplina, archivo_standar, ruta_standar, archivo, ruta, ISNULL(usuario_mod, usuario) usuario, ISNULL(CONVERT(VARCHAR, fh_mod, 0), CONVERT(VARCHAR, fh, 0)) fh FROM [DisciplinasOperacionales].[dbo].[Disciplinas] C "
                                + "LEFT JOIN "
                                + "(SELECT ISNULL(A.codigo, B.codigo) codigo, archivo_standar, ruta_standar, archivo, ruta, usuario, usuario_mod, fh, fh_mod FROM (SELECT codigo, archivo [archivo_standar], ruta [ruta_standar] FROM [DisciplinasOperacionales].[dbo].[Contenido] WHERE standar = 'True') A "
                                + "FULL JOIN "
                                + "(SELECT codigo, archivo, ruta, usuario, fh, usuario_mod, fh_mod FROM[DisciplinasOperacionales].[dbo].[Contenido] WHERE planta = '" + lblPlanta.Text + "') B "
                                + "ON A.codigo = B.codigo) D ON C.codigo = D.codigo where C.Departamento "+ cond ;
        dtContenido = sql.selec(qryContenido);
 
        if (dtContenido.Rows.Count > 0)
        {
            tablaContenido += "<table class='table' id='tablaContenido' width='100%'>"
                                + "<thead>"
                                    + "<tr class='tr-tipoOSA text-center' style='font-size: 13px;'>"
                                        + "<th>C&oacute;digo</th>"
                                        + "<th>Elemento</th>"
                                        + "<th>Disciplina</th>"
                                        + "<th>Archivo</th>"
                                        + "<th>Cargado por</th>"
                                        + "<th>Fecha de carga</th>"
                                    + "</tr>"
                                + "</thead>"
                                + "<tbody style='font-size: 12px;'>";

            foreach (DataRow r in dtContenido.Rows)
            {
                if (r["archivo_standar"].ToString() == "" && r["archivo"].ToString() == "")
                {
                    inputArchivo += "<input type='file' name='archivo" + r["codigo"].ToString() + "' id='archivo" + r["codigo"].ToString() + "' />";
                }
                else
                {
                    if (r["archivo_standar"].ToString() != "")
                    {
                        datos = r["archivo_standar"].ToString().Split('_');

                        inputArchivo += CrearPopover(datos[3], r["archivo_standar"].ToString());
                    }

                    if (r["archivo"].ToString() != "")
                    {
                        datos = r["archivo"].ToString().Split('_');

                        inputArchivo += CrearPopover(datos[3], r["archivo"].ToString());
                    }

                    if (r["archivo_standar"].ToString() == r["archivo"].ToString())
                    {
                        datos = r["archivo_standar"].ToString().Split('_');

                        inputArchivo = CrearPopover(datos[3], r["archivo_standar"].ToString());
                    }

                    inputArchivo += "<div class='pull-right'><input class='pull-right' type='file' name='archivo" + r["codigo"].ToString() + "' id='archivo" + r["codigo"].ToString() + "' /></div>";
                }

                tablaContenido += "<tr style='font-size: 12px;'>"
                                    + "<td class='text-center'>" + r["codigo"].ToString() + "</td>"
                                    + "<td class='text-center'>" + r["elemento"].ToString() + "</td>"
                                    + "<td>" + r["disciplina"].ToString() + "</td>"
                                    + "<td>" + inputArchivo + "</td>"
                                    + "<td class='text-center'>" + r["usuario"].ToString() + "</td>"
                                    + "<td class='text-center'>" + r["fh"].ToString() + "</td>"
                                + "</tr>";

                inputArchivo = "";
            }

            tablaContenido += "</tbody></table>";
            litContDinamico.Text = tablaContenido;
        }
    }

    public string CrearPopover(string archivo, string ruta)
    {
        string popover = "";

        if (ObtenerExtension(archivo) == "ppt" || ObtenerExtension(archivo) == "pptx")
        {
            popover += "<div data-toggle='popover' data-container='body' data-placement='top' data-html='true' data-content='<embed src=\"dinamico/" + Path.GetFileNameWithoutExtension(ruta) + ".pdf" + "\" type=\"application/pdf\" width=\"700px\" height=\"600px\">' class='pull-left'><img src='img/" + Extension(ruta) + "' width='35' height='35'>&nbsp;<span>" + archivo + "</span></div>";
        }
        else if (ObtenerExtension(archivo) == "pdf")
        {
            popover += "<div data-toggle='popover' data-container='body' data-placement='top' data-html='true' data-content='<embed src=\"dinamico/" + Path.GetFileNameWithoutExtension(ruta) + "\" type=\"application/pdf\" width=\"500px\" height=\"500px\">' class='pull-left'><img src='img/" + Extension(ruta) + "' width='35' height='35'>&nbsp;<span>" + archivo + "</span></div>";
        }
        else
        {
            popover += "<div data-toggle='popover' data-container='body' data-placement='top' data-html='true' data-content='<img src=\"dinamico/" + Path.GetFileNameWithoutExtension(ruta) + "\" width=\"100%\" height=\"100%\">' class='pull-left'><img src='img/" + Extension(ruta) + "' width='35' height='35'>&nbsp;<span>" + archivo + "</span></div>";
        }

        return popover;
    }

    protected void btnActualizar_Click(object sender, EventArgs e)
    {
        dtContenido = sql.selec("SELECT A.codigo, elemento, disciplina, B.archivo, usuario, fh FROM [DisciplinasOperacionales].[dbo].[Disciplinas] A "
                                + "LEFT JOIN "
                                + "(SELECT codigo, archivo, usuario, fh FROM [DisciplinasOperacionales].[dbo].[Contenido] WHERE planta = '" + lblPlanta.Text + "') B "
                                + "ON A.codigo = B.codigo");

        if (dtContenido.Rows.Count > 0)
        {
            HttpPostedFile archivo;
            server = Server.MapPath("~/dinamico/");

            foreach (DataRow r in dtContenido.Rows)
            {
                codigo = "archivo" + r["codigo"].ToString();

                if (Request.Files[codigo] != null)
                {
                    archivo = Request.Files[codigo];
                    nombre_archivo = Path.GetFileName(archivo.FileName);

                    if (archivo.ContentLength > 0)
                    {
                        fh = DateTime.Now.Year + "-" + DateTime.Now.Month + "-" + DateTime.Now.Day + "-" + DateTime.Now.Hour + "-" + DateTime.Now.Minute + "-" + DateTime.Now.Second;
                        nombre_archivo = lblPlanta.Text.Replace(" ", "") + "_" + r["codigo"].ToString() + "_" + fh + "_" + Path.GetFileName(archivo.FileName.Replace("@", "").Replace("_", " ").Replace("'", "").Replace("\"", "").Replace("&", "").ToLower());

                        archivo.SaveAs(server + nombre_archivo);

                        if (ObtenerExtension(nombre_archivo) == "ppt" || ObtenerExtension(nombre_archivo) == "pptx")
                        {
                            powerpoint = Presentation.Open(server + nombre_archivo);
                            pdf = PresentationToPdfConverter.Convert(powerpoint);
                            pdf.Save(server + Path.GetFileNameWithoutExtension(nombre_archivo) + ".pdf");
                            pdf.Close(true);
                            powerpoint.Close();
                        }

                        if (r["archivo"].ToString() != "")
                        {
                            sql.exec("UPDATE [DisciplinasOperacionales].[dbo].[Contenido] SET archivo = '" + nombre_archivo + "', ruta = 'dinamico/" + nombre_archivo + "', usuario_mod = '" + lblNombre.Text + "', fh_mod = GETDATE() WHERE codigo = '" + r["codigo"].ToString() + "' AND planta = '" + lblPlanta.Text + "'");
                        }
                        else
                        {
                            sql.exec("INSERT INTO [DisciplinasOperacionales].[dbo].[Contenido] (codigo, archivo, ruta, planta, usuario, standar) VALUES ('" + r["codigo"].ToString() + "','" + nombre_archivo + "','dinamico/" + nombre_archivo + "','" + lblPlanta.Text + "','" + lblNombre.Text + "','False')");
                        }
                    }
                }
            }

            litMensaje.Text = "<script>swal({title: '', text: 'El contenido dinámico se ha actualizado correctamente.',type: 'success', confirmButtonClass: 'btn-success', confirmButtonText: 'OK', closeOnConfirm: false},function(){  window.location.href = 'ContenidoDinamico.aspx?&us=" + lblUsuario.Text + "&nombre=" + lblNombre.Text + "&p=" + lblPlanta.Text + "'; });</script>";
        }
    }

    public string Extension(string archivo)
    {
        string ext = "";
        ext = archivo.Substring(archivo.LastIndexOf('.') + 1) + ".png";
        return ext;
    }

    public string ObtenerExtension(string archivo)
    {
        string ext = "";
        ext = archivo.Substring(archivo.LastIndexOf('.') + 1);
        return ext;
    }
}