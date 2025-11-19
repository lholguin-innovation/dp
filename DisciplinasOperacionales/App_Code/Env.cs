using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;
using System.Net;
using System.IO;
using System.Web.Services;  

public class Env
{ 
    static public string redirectUrl="/mci2/Default2.aspx?u=/DisciplinasOperacionales/Resumen.aspx";
    static public string sqlServerSecundario  = "dlgrv74w1\\SQLEXPRESS"; 
    static public string sqlServerSecundarioPass = "edseps03";
    static public string app_server = "USASHPMCIDB01";
    static public string Server_DB05 = "USVIASH-DB05";
    static public string app_user = "apps";
    static public string app_password = "99552499*";
    static public string db_server = "usashpmcidb01";
    static public string db_user = "apps";
    static public string db_password = "99552499*";
    
	public static string getDbConnectionString(string dbName = "KPI")
    {
        return string.Format(@"Server=" + Env.db_server + ";Database=" + dbName + ";Uid=" + Env.db_user + ";Pwd=" + Env.db_password + ";pooling=false;");
    }
    public static string getDB05ConnectionString(string dbName = "DTv2")
    {
        return string.Format(@"Server=" + Env.Server_DB05 + ";Database=" + dbName + ";Uid=" + Env.db_user + ";Pwd=" + Env.db_password + ";pooling=false;");
    }
    public static string getAppServerDbConnectionString(string dbName = "DTv2")
    {

    //    return string.Format(@"Server=" + Env.sqlServerSecundario + ";Database=" + dbName + ";Uid=" + "sa" + ";Pwd=" +"99552499*"+ ";pooling=false;");
        return string.Format(@"Server=" + Env.app_server + ";Database=" + dbName + ";Uid=" + Env.app_user + ";Pwd=" + Env.app_password + ";pooling=false;");
    }
	
	public static string Post(string url,object parameters){
        string output = "";
		byte[] bytes = Encoding.UTF8.GetBytes(JsonConvert.SerializeObject(parameters));
		
        HttpWebRequest request = (HttpWebRequest)HttpWebRequest.Create(url);
        request.Method = WebRequestMethods.Http.Post;
		request.ContentType = "application/json; charset=utf-8";
		request.Accept = "application/json";
		request.Timeout = 800000;
		request.ReadWriteTimeout = 800000;
		
		using (var stream = request.GetRequestStream())
		{
			stream.Write(bytes, 0, bytes.Length);
		}
		
		using (HttpWebResponse response = (HttpWebResponse)request.GetResponse())
		{
			StreamReader reader = new StreamReader(response.GetResponseStream());
			output = reader.ReadToEnd();
			response.Close();
		}
		
        return output;
    }

    public static string Get(string uri)
    {
        HttpWebRequest request = (HttpWebRequest)WebRequest.Create(uri);
        request.AutomaticDecompression = DecompressionMethods.GZip | DecompressionMethods.Deflate;

        using(HttpWebResponse response = (HttpWebResponse)request.GetResponse())
        using(Stream stream = response.GetResponseStream())
        using(StreamReader reader = new StreamReader(stream))
        {
            return reader.ReadToEnd();
        }
    }
}