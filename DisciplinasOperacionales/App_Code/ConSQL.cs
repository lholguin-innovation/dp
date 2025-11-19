using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI.WebControls;

public class ConSQL
{
    SqlConnection con;
    SqlCommand cmd;
    SqlDataAdapter da;
    SqlBulkCopy bc;
    DataTable dt;

    public ConSQL()
    {
    }
    public ConSQL(string cadena)
    {
        con = new SqlConnection(cadena);
        abrir();
    }

    private void abrir()
    {
        if (con.State != ConnectionState.Closed)
        {
            con.Close();
        }
        con.Open();
    }

    private void cerrar()
    {
        if (con == null) return;
        if (con.State != ConnectionState.Closed)
        {
            con.Close();
        }
    }

    public DataTable selec(string query)
    {
        DataTable dt = new DataTable();
        try
        {
            abrir();
            cmd = new SqlCommand(query, con);
            cmd.CommandTimeout = 300;
            da = new SqlDataAdapter(cmd);
            da.Fill(dt);
            cerrar();
        }
        catch (Exception ex)
        {
            cerrar();
        }
        return dt;
    }

    public object scalar(string query)
    {
        object scr = null;
        try
        {
            abrir();
            cmd = new SqlCommand(query, con);
            cmd.CommandTimeout = 300;
            scr = cmd.ExecuteScalar();
            cerrar();
        }
        catch (Exception ex)
        {
            cerrar();
        }
        return scr;
    }

    public int exec(string query)
    {
        int exr = 0;
        try
        {
            abrir();
            cmd = new SqlCommand(query, con);
            cmd.CommandTimeout = 300;
            exr = cmd.ExecuteNonQuery();
            cerrar();
        }
        catch (Exception ex)
        {
            cerrar();
        }

        return exr;
    }

    public int copiaBulto(DataTable dt, string tabla)
    {
        int regis = 0;

        try
        {
            abrir();
            bc = new SqlBulkCopy(con);
            foreach (DataColumn col in dt.Columns)
            {
                bc.ColumnMappings.Add(col.ColumnName, col.ColumnName);
            }

            bc.DestinationTableName = tabla.Trim();
            bc.WriteToServer(dt);
            bc.Close();
            regis = dt.Rows.Count;

        }
        catch (Exception ex)
        {
            cerrar();
        }

        return regis;
    }

    public void llenaCombo(DropDownList ddl, DataTable dt, string valor, string texto)
    {
        try
        {
            ddl.DataSource = dt;
            ddl.DataTextField = texto;
            ddl.DataValueField = valor;
            ddl.DataBind();
        }
        catch (Exception ex)
        {
            cerrar();
        }
    }

    public void llenaDropDownList(DropDownList ddl, DataTable dt, string valor, string texto)
    {
        try
        {
            ddl.DataSource = dt;
            ddl.DataTextField = texto;
            ddl.DataValueField = valor;
            ddl.DataBind();
        }
        catch (Exception ex)
        {
            cerrar();
        }
    }

    public void llenaListBoX(ListBox ddl, DataTable dt, string valor, string texto)
    {
        try
        {
            ddl.DataSource = dt;
            ddl.DataTextField = texto;
            ddl.DataValueField = valor;
            ddl.SelectionMode = ListSelectionMode.Multiple;
            ddl.DataBind();
        }
        catch (Exception ex)
        {
            cerrar();
        }
    }

    public DataTable ConsultaProcedure(DataTable tabla, string procedimiento, string variable)
    {
        dt = new DataTable();

        try
        {
            abrir();
            cmd = new SqlCommand(procedimiento, con);
            cmd.CommandTimeout = 900;
            cmd.CommandType = CommandType.StoredProcedure;
            SqlParameter parametro = cmd.Parameters.AddWithValue(variable, tabla);
            parametro.SqlDbType = SqlDbType.Structured;
            da = new SqlDataAdapter(cmd);
            da.Fill(dt);
            cerrar();
        }
        catch (Exception x)
        {
            cerrar();
        }

        return dt;  
    }

    public int ExecProcedure(DataTable tabla, string procedimiento, string variable)
    {
        dt = new DataTable();
        int exr = 0;

        try
        {
            abrir();
            cmd = new SqlCommand(procedimiento, con);
            cmd.CommandTimeout = 900;
            cmd.CommandType = CommandType.StoredProcedure;
            SqlParameter parametro = cmd.Parameters.AddWithValue(variable, tabla);
            parametro.SqlDbType = SqlDbType.Structured;
            exr = cmd.ExecuteNonQuery();
            cerrar();
        }
        catch (Exception x)
        {
            cerrar();
        }

        return exr;
    }
}