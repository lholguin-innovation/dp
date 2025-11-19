using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Registro : System.Web.UI.Page
{
    public ConSQL sql;

    protected void Page_Load(object sender, EventArgs e)
    {
        //sql = new ConSQL("Server=10.223.36.253\\SQLExpress;Database=DTv2;Uid=sa;Pwd=99552499*;pooling=false;");
      //  sql = new ConSQL(Env.getAppServerDbConnectionString("DTv2"));
        sql = new ConSQL(Env.getDbConnectionString("DTv2"));

        if (!IsPostBack)
        {
            sql.llenaDropDownList(ddlPlanta, sql.selec("SELECT '' AS planta UNION ALL SELECT DISTINCT planta FROM [DTv2].[dbo].[Cat_Plantas]"), "planta", "planta");
            sql.llenaDropDownList(ddlArea, sql.selec("SELECT '' AS area UNION ALL SELECT DISTINCT area FROM [DTv2].[dbo].[Areas]"), "area", "area");
        }
        else
        {
            litmensaje.Text = "";
        }
    }

    protected void btnGuardar_Click(object sender, EventArgs e)
    {
        string error = "";

        if (txtNombre.Text == "")
        {
            error += " nombre,";
        }
        if (ddlPlanta.SelectedItem.Text == "")
        {
            error += " planta,";
        }
        if (ddlArea.SelectedItem.Text == "")
        {
            error += " area,";
        }
        if (txtNetID.Text == "")
        {
            error += " NetId,";
        }
        if (txtEmail.Text == "")
        {
            error += " email,";
        }

        if (error == "")
        {

            int usuario = Convert.ToInt32(sql.scalar("SELECT COUNT(*) AS cuantos FROM [DTv2].[dbo].[Cat_Usuarios] WHERE NetId = '" + txtNetID.Text + "'"));

            if (usuario == 0)
            {
                int insertar = 0;

                insertar = sql.exec("INSERT INTO [DTv2].[dbo].[Cat_Usuarios] (Nombre,Planta,Area,Email,NetId,Admin,Tipo_Admin) VALUES ('" + txtNombre.Text + "','" + ddlPlanta.SelectedItem.Text + "','" + ddlArea.SelectedItem.Text + "','" + txtEmail.Text + "','" + txtNetID.Text + "',0,'NORMAL')");

                if (insertar != 0)
                {
                    litmensaje.Text = "<script>swal('','Usuario registrado correctamente.','success');</script>";
                    txtNombre.Text = "";
                    txtNetID.Text = "";
                    txtEmail.Text = "";
                    ddlArea.SelectedIndex = ddlArea.Items.IndexOf(ddlArea.Items.FindByText(""));
                    ddlPlanta.SelectedIndex = ddlPlanta.Items.IndexOf(ddlPlanta.Items.FindByText(""));
                }
            }
            else
            {
                litmensaje.Text = "<script>swal('','Este usuario ya esta registrado. Intenta con uno diferente.','warning');</script>";
            }
        }
        else
        {
            error = error.Remove(error.Length - 1, 1);
            litmensaje.Text = "<script>swal('','Necesitas agregar" + error + ".','warning');</script>";
        }
    }
}