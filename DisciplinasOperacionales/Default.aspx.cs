using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.DirectoryServices;
using FormsAuth;

public partial class _Default : System.Web.UI.Page
{
    public ConSQL conCentral;
    public String adPath = "LDAP://lear.com";
    public string dominio = "CORPLEAR";

    protected void Page_Load(object sender, EventArgs e)
    {
        /*Response.Redirect("/mci2/Default2.aspx");

        conCentral = new ConSQL(Env.getDbConnectionString());

        Session["nombre"] = "";
        Session["planta"] = "";
        Session["area"] = "";
        Session["netid"] = "";

        if (!IsPostBack) { }
        else
        {
            litmensaje.Text = "";
        }*/
    }

    protected void btnEntrar_Click(object sender, EventArgs e)
    {
        if (txtNetId.Text != "" && txtPass.Text != "")
        {
            DataTable info;

            /*try
            {*/
                //info = conCentral.selec("SELECT * FROM [DTv2].[dbo].[Cat_Usuarios] WHERE NetId = '" + txtNetId.Text.Trim() + "'");

                /*if (info.Rows.Count > 0 || 1>0)
                { */  
                    LdapAuthentication adAuth = new LdapAuthentication(adPath);

                    if (true == adAuth.IsAuthenticated(dominio, txtNetId.Text.Trim(), txtPass.Text.Trim()))
                    {
                        litmensaje.Text = "<script>swal('','Success.','error');</script>";
                        
                        /*foreach (DataRow r in info.Rows)
                        {
                            Session["Nombre"] = r["Nombre"].ToString();
                            Session["Planta"] = r["Planta"].ToString();
                            Session["Area"] = r["Area"].ToString();
                            Session["NetId"] = r["NetId"].ToString(); 
                            Session["Email"] = r["Email"].ToString(); 
                            Session["Admin"] = r["Admin"].ToString(); 
                            Session["Nivel"]    = r["Nivel"].ToString(); 
                            Session["Tipo_Admin"] = r["Tipo_Admin"].ToString(); 

                            string sqlDatosPlanta = "SELECT * FROM [CatPlantas].[dbo].[Cat_Plantas] WHERE planta = '" + r["Planta"].ToString()  + "'";
                            DataTable dtDatosPlanta =conCentral.selec(sqlDatosPlanta );
                            if(dtDatosPlanta.Rows.Count > 0 ) {
                                    
                                Session.Add("cadenaConCatPlantas", Env.getDbConnectionString());  
                                Session.Add("id_planta",     dtDatosPlanta.Rows[0]["id_planta"].ToString());
                                Session.Add("serverSQL",     dtDatosPlanta.Rows[0]["serverSQL"].ToString());
                                Session.Add("server_planta", dtDatosPlanta.Rows[0]["server"].ToString());
                                Session.Add("servidor_web",  dtDatosPlanta.Rows[0]["servidor_web"].ToString());
                                Session.Add("clave_planta",  dtDatosPlanta.Rows[0]["clave_planta"].ToString());
                                Session.Add("camarillas",    dtDatosPlanta.Rows[0]["camarillas"].ToString());
                                Session.Add("tool_crib",     dtDatosPlanta.Rows[0]["tool_crib"].ToString());
                                Session.Add("servidor_SAM", dtDatosPlanta.Rows[0]["SAM"].ToString());
                                Session.Add("base_SAM",     dtDatosPlanta.Rows[0]["base_SAM"].ToString());
                                Session.Add("link_DT",      dtDatosPlanta.Rows[0]["link_DT"].ToString());
                                Session.Add("link_mysql",   dtDatosPlanta.Rows[0]["link_mysql"].ToString());
                                Session.Add("MySqlServer",  dtDatosPlanta.Rows[0]["MySqlServer"].ToString());
                                Session.Add("pagina1",      dtDatosPlanta.Rows[0]["pagina1"].ToString());
                                Response.Redirect("Menu.aspx?us=" + Session["NetId"] + "&nombre=" + Session["Nombre"]);

                            } else{ 
                                litmensaje.Text = "<script>swal('','No se encontro la planta.','error');</script>";
                            }
                        }*/
                    }
                    else
                    {
                        litmensaje.Text = "<script>swal('','Usuario no encontrado o contraseña incorrecta, por favor revisa tu información.','error');</script>";
                    } 
                /*}
                else
                {
                    litmensaje.Text = "<script>swal('','El usuario no esta registrado.','error');</script>";
                }*/
            /*}
            catch (Exception x)
            {
                litmensaje.Text = "<script>swal('','Usuario no encontrado o contraseña incorrecta, porfavor revisa tu información.','error');</script>";
            }*/
        }
        else
        {
            litmensaje.Text = "<script>swal('','Favor de llenar los campos solicitados.','error');</script>";
        }
    }
}