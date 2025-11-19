using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Security.Principal;
using System.Data;
using System.DirectoryServices;
using FormsAuth;

public partial class Logout : System.Web.UI.Page
{
    public ConSQL sql;
	public string cadConCatPlantas;
    public String adPath = "LDAP://aptiv.com";
    public string dominio = "APTIV";
    public string animacion;

    protected void Page_Load(object sender, EventArgs e)
    { 
      
      Session.Abandon();
     // Response.Redirect("Default.aspx");
      Response.Redirect(Env.redirectUrl);
    }

 }