<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Text.RegularExpressions" %>
<%@ Import Namespace="System.Data" %>

<script runat="server">
    string connectionString = "Server=mxchlac-sql04;Database=LAIMS;User Id=sqlIIT;Password=Le@r2025!iitdata;MultipleActiveResultSets=True;";


    protected void Page_Load(object sender, EventArgs e)                  
    {
        Response.ContentType = "application/json";
        string jsonInput;

        using (StreamReader reader = new StreamReader(Request.InputStream))
        {
            jsonInput = reader.ReadToEnd();
        }

        dynamic input = JsonConvert.DeserializeObject(jsonInput);
        int operation = input.Operation;

        switch (operation)
        {
            case 0:
                GetModulesByPlant((int)input.idPlant);
                break;

            case 1:
                GetGeneralReport(input.FechaInicio.ToString(), input.FechaFin.ToString(),Convert.ToInt32(input.Turno), input.idMachines.ToString(), input.groupBy.ToString());
                 /*Response.Write(JsonConvert.SerializeObject(new {
                    Fecha = input.Fecha,
                    Turno = Convert.ToInt32(input.Turno),
                    idMachines = input.idMachines
                }));*/
                break;

            default:
                Response.Write(JsonConvert.SerializeObject(new {
                    error = "Invalid operation code."
                }));
                break;
        }

        Response.End();
    }

        private void GetModulesByPlant(int idPlant)
        {
            var modules = new List<object>();

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string query = @"
                    SELECT [Id] AS idModule,
                        [Alias],
                        [Machine_IDs]
                    FROM [Catalogos].[dbo].[Cat_Modules]
                    WHERE idPlant = @idPlant";

                conn.Open();

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@idPlant", idPlant);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            int idModule = Convert.ToInt32(reader["idModule"]);
                            string alias = reader["Alias"].ToString();
                            string machine_ids = reader["Machine_IDs"].ToString();

                            // Obtener máquinas para este módulo
                            var Machines = new List<string>();
                            string m_query = "SELECT CONCAT([index], ' - ', MTO) AS MachineName FROM Catalogos.dbo.Cat_Machines WHERE idPlant = @idPlant AND idModule = @idModule";

                            using (SqlCommand m_cmd = new SqlCommand(m_query, conn))
                            {
                                m_cmd.Parameters.AddWithValue("@idPlant", idPlant);
                                m_cmd.Parameters.AddWithValue("@idModule", idModule);

                                using (SqlDataReader m_reader = m_cmd.ExecuteReader())
                                {
                                    while (m_reader.Read())
                                    {
                                        Machines.Add(m_reader["MachineName"].ToString());
                                    }
                                }
                            }

                            modules.Add(new
                            {
                                idModule = idModule,
                                Alias = alias,
                                machine_ids = machine_ids,
                                Machines = Machines
                            });
                        }
                    }
                }
            }

            var response = new { modules = modules };
            Response.Write(JsonConvert.SerializeObject(response));
        }


        private void GetGeneralReport(string Fechastri, string Fechastrf, int turno, string Machine_IDs, string rangeType)
        {
            var report = new List<object>();
            string query = "";
            SqlConnection conn = null;

            try
            {
                switch (rangeType)
                {
                    case "hour":
                        query = DailyQuery(Fechastri, Fechastrf, turno, Machine_IDs);
                        /*Response.Write(JsonConvert.SerializeObject(new { error = "Invalid Range Type", query }));
                        return;*/
                        break;
                    case "day":
                        query = DaysQuery(Fechastri, Fechastrf, turno, Machine_IDs);                        
                        break;
                    case "week":
                        query = weeklyQuery(Fechastri, Fechastrf, turno, Machine_IDs);
                        break;
                    case "month":
                        query = MonthlyQuery(Fechastri, Fechastrf, turno, Machine_IDs);
                        break;
                    default:
                        Response.StatusCode = 400;
                        Response.Write(JsonConvert.SerializeObject(new { error = "Invalid Range Type", query }));
                        return;
                }

                conn = new SqlConnection(connectionString);
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            var row = new Dictionary<string, object>();

                            for (int i = 0; i < reader.FieldCount; i++)
                            {
                                string columnName = reader.GetName(i);
                                row[columnName] = reader.GetValue(i);
                            }

                            report.Add(row);
                        }
                    }
                }

                Response.Write(JsonConvert.SerializeObject(new { report }));
            }
            catch (Exception ex)
            {
                Response.StatusCode = 500;
                Response.Write(JsonConvert.SerializeObject(new
                {
                    error = ex.Message,
                    status = 500,
                    query
                }));
            }
            finally
            {
                if (conn != null && conn.State != ConnectionState.Closed)
                {
                    conn.Close();
                }
            }
        }

           private string DailyQuery(string Fechastri, string Fechastrf, int turno, string Machine_IDs)
            {
                DateTime FechaInicio;
                DateTime FechaFin;

                if (!DateTime.TryParse(Fechastri, out FechaInicio) || !DateTime.TryParse(Fechastrf, out FechaFin))
                {
                    return "-- Invalid date format";
                }

                int HoraInicio, HoraFin;
                double horasDisponiblesPorDia = 0;

                switch (turno)
                {
                    case 1:
                        HoraInicio = 6;
                        HoraFin = 15;
                        horasDisponiblesPorDia = 8.45;
                        break;
                    case 2:
                        HoraInicio = 15;
                        HoraFin = 24;
                        horasDisponiblesPorDia = 7.45;
                        break;
                    case 3:
                        HoraInicio = 0;
                        HoraFin = 5;
                        horasDisponiblesPorDia = 5.5;
                        break;
                    case 0:
                        HoraInicio = 0;
                        HoraFin = 24;
                        horasDisponiblesPorDia = 21.4;
                        break;
                    default:
                        return "-- Invalid shift value";
                }

                var queryBuilder = new StringBuilder();
                var baseBuilder = new StringBuilder();
                int length = Machine_IDs.Split(',').Select(e => e.Trim()).ToArray().Length;

                // Construimos la CTE Base con rangos de hora únicos (sin fechas)
                baseBuilder.AppendLine("WITH Base AS (");

                for (int h = HoraInicio; h <= HoraFin; h++)
                {
                    string rango = ObtenerRangoHorario(h, turno);
                    baseBuilder.AppendLine("    SELECT '" + rango + "' AS Hour, " + h + " AS HourInt UNION ALL");
                }

                // Eliminamos el último UNION ALL
                int lastUnionIndex = baseBuilder.ToString().LastIndexOf("UNION ALL");
                if (lastUnionIndex >= 0)
                {
                    baseBuilder.Remove(lastUnionIndex, "UNION ALL".Length);
                }
                baseBuilder.AppendLine(")");

                queryBuilder.Append(baseBuilder);

                // SELECT principal agrupado por rango de hora
                queryBuilder.AppendLine(
                    "SELECT " +
                    "    Base.Hour, " +
                    "    ISNULL(SUM(m.Request), 0) AS [Request], " +
                    "    ISNULL(SUM(m.Produced), 0) AS [Produced], " +
                    "    CONCAT( " +
                    "        CAST( " +
                    "            CASE " +
                    "                WHEN ISNULL(SUM(m.Request), 0) = 0 THEN 0 " +
                    "                ELSE CAST(ISNULL(SUM(m.Produced), 0) AS DECIMAL(18,2)) / CAST(SUM(m.Request) AS DECIMAL(18,2)) * 100 " +
                    "            END " +
                    "        AS DECIMAL (18,2)), '%' " +
                    "    ) AS [Efficiency], " +
                    "    ROUND(ISNULL(SUM(m.Utilization), 0) / 60, 2) AS [Utilization Mins], " +
                    "    CONCAT( " +
                    "        ROUND(ISNULL(SUM(m.Utilization), 0) / 60 / (57 * " + length + ") * 100, 2), '%' " +
                    "    ) AS [Utilization %] " +
                    "FROM Base " +
                    "LEFT JOIN ShopFloor.dbo.ModbusMachineHistory m ON " +
                    "    DATEPART(HOUR, m.Hora) = Base.HourInt " +
                    "    AND m.MachineID IN (" + Machine_IDs + ") " +
                    "    AND DATEPART(HOUR, m.Hora) BETWEEN " + HoraInicio + " AND " + HoraFin + " " +
                    "    AND CAST(m.Hora AS DATE) BETWEEN '" + FechaInicio.ToString("yyyy-MM-dd") + "' AND '" + FechaFin.ToString("yyyy-MM-dd") + "' " +
                    "GROUP BY Base.Hour "
                );

                return queryBuilder.ToString();
            }

             private string DaysQuery(string Fechastri, string Fechastrf, int turno, string Machine_IDs)
            {
                DateTime FechaInicio;
                DateTime FechaFin;

                if (!DateTime.TryParse(Fechastri, out FechaInicio) || !DateTime.TryParse(Fechastrf, out FechaFin))
                {
                    return "-- Invalid date format";
                }

                int HoraInicio, HoraFin;
                double horasDisponiblesPorDia = 0;

                switch (turno)
                {
                    case 1:
                        HoraInicio = 6;
                        HoraFin = 15;
                        horasDisponiblesPorDia = 8.45;
                        break;
                    case 2:
                        HoraInicio = 15;
                        HoraFin = 24;
                        horasDisponiblesPorDia = 7.45;
                        break;
                    case 3:
                        HoraInicio = 0;
                        HoraFin = 5;
                        horasDisponiblesPorDia = 5.5;
                        break;
                    case 0:
                        HoraInicio = 0;
                        HoraFin = 24;
                        horasDisponiblesPorDia = 21.4;
                        break;
                    default:
                        return "-- Invalid shift value";
                }

                var queryBuilder = new StringBuilder();
                var baseBuilder = new StringBuilder();
                var current = FechaInicio.Date;
                int length = Machine_IDs.Split(',').Select(e => e.Trim()).ToArray().Length;

                // Construimos la CTE Base con todas las fechas
                baseBuilder.AppendLine("WITH Base AS (");

                while (current <= FechaFin.Date)
                {
                    string fechaStr = current.ToString("yyyy-MM-dd");
                    baseBuilder.AppendLine("    SELECT CAST('" + fechaStr + "' AS DATE) AS StartDate UNION ALL");
                    current = current.AddDays(1);
                }

                // Eliminamos el último UNION ALL
                int lastUnionIndex = baseBuilder.ToString().LastIndexOf("UNION ALL");
                if (lastUnionIndex >= 0)
                {
                    baseBuilder.Remove(lastUnionIndex, "UNION ALL".Length);
                }
                baseBuilder.AppendLine(")");

                queryBuilder.Append(baseBuilder);

                // SELECT principal agrupado por día
                queryBuilder.AppendLine(
                    "SELECT " +
                    "    Base.StartDate AS [Date], " +
                    "    ISNULL(SUM(m.Request), 0) AS [Request], " +
                    "    ISNULL(SUM(m.Produced), 0) AS [Produced], " +
                    "    CONCAT( " +
                    "        CAST( " +
                    "            CASE " +
                    "                WHEN ISNULL(SUM(m.Request), 0) = 0 THEN 0 " +
                    "                ELSE CAST(ISNULL(SUM(m.Produced), 0) AS DECIMAL(18,2)) / CAST(SUM(m.Request) AS DECIMAL(18,2)) * 100 " +
                    "            END " +
                    "        AS DECIMAL (18,2)), '%' " +
                    "    ) AS [Efficiency], " +
                    "    ROUND(ISNULL(SUM(m.Utilization), 0) / 60, 2) AS [Utilization Mins], " +
                    "    CONCAT( " +
                    "        ROUND(ISNULL(SUM(m.Utilization), 0) / 60 / (57 * " + length + ") * 100, 2), '%' " +
                    "    ) AS [Utilization %] " +
                    "FROM Base " +
                    "LEFT JOIN ShopFloor.dbo.ModbusMachineHistory m ON " +
                    "    CAST(m.Hora AS DATE) = Base.StartDate " +
                    "    AND m.MachineID IN (" + Machine_IDs + ") " +
                    "    AND DATEPART(HOUR, m.Hora) BETWEEN " + HoraInicio + " AND " + HoraFin + " " +
                    "GROUP BY Base.StartDate " +
                    "ORDER BY Base.StartDate"
                );

                return queryBuilder.ToString();
            }


        private string weeklyQuery(string Fechastri, string Fechastrf, int turno, string Machine_IDs)
        {
            DateTime FechaInicio;
            DateTime FechaFin;

            if (!DateTime.TryParse(Fechastri, out FechaInicio) || !DateTime.TryParse(Fechastrf, out FechaFin))
            {
                return "-- Invalid date format";
            }

            int HoraInicio, HoraFin;
            double horasDisponiblesPorDia = 0;

            switch (turno)
            {
                case 1:
                    HoraInicio = 6;
                    HoraFin = 15;
                    horasDisponiblesPorDia = 8.45;
                    break;
                case 2:
                    HoraInicio = 15;
                    HoraFin = 24;
                    horasDisponiblesPorDia = 7.45;
                    break;
                case 3:
                    HoraInicio = 0;
                    HoraFin = 5;
                    horasDisponiblesPorDia = 5.5;
                    break;
                case 0:
                    HoraInicio = 0;
                    HoraFin = 24;
                    horasDisponiblesPorDia = 21.4;
                    break;
                default:
                    return "-- Invalid shift value";
            }

            int length = Machine_IDs.Split(',').Select(e => e.Trim()).ToArray().Length;

            // Construcción del query agrupado por semana
            string query =
                "SELECT " +
                "    CONCAT('W', DATEPART(WEEK, m.Hora)) AS [Week], " +
                "    ISNULL(SUM(m.Request), 0) AS [Request], " +
                "    ISNULL(SUM(m.Produced), 0) AS [Produced], " +
                "    CONCAT( " +
                "        CAST( " +
                "            CASE " +
                "                WHEN ISNULL(SUM(m.Request), 0) = 0 THEN 0 " +
                "                ELSE CAST(ISNULL(SUM(m.Produced), 0) AS DECIMAL(18,2)) / CAST(SUM(m.Request) AS DECIMAL(18,2)) * 100 " +
                "            END " +
                "        AS DECIMAL (18,2)), '%' " +
                "    ) AS [Efficiency], " +
                "    ROUND(ISNULL(SUM(m.Utilization), 0) / 60, 2) AS [Utilization Mins], " +
                "    CONCAT( " +
                "        ROUND(ISNULL(SUM(m.Utilization), 0) / 60 / (57 * " + length + ") * 100, 2), '%' " +
                "    ) AS [Utilization %] " +
                "FROM ShopFloor.dbo.ModbusMachineHistory m " +
                "WHERE CAST(m.Hora AS DATE) BETWEEN '" + FechaInicio.ToString("yyyy-MM-dd") + "' AND '" + FechaFin.ToString("yyyy-MM-dd") + "' " +
                "    AND m.MachineID IN (" + Machine_IDs + ") " +
                "    AND DATEPART(HOUR, m.Hora) BETWEEN " + HoraInicio + " AND " + HoraFin + " " +
                "GROUP BY DATEPART(WEEK, m.Hora) " +
                "ORDER BY DATEPART(WEEK, m.Hora)";

            return query;
        }

private string MonthlyQuery(string Fechastri, string Fechastrf, int turno, string Machine_IDs)
{
    DateTime FechaInicio;
    DateTime FechaFin;

    if (!DateTime.TryParse(Fechastri, out FechaInicio) || !DateTime.TryParse(Fechastrf, out FechaFin))
    {
        return "-- Invalid date format";
    }

    int HoraInicio, HoraFin;
    double horasDisponiblesPorDia = 0;

    switch (turno)
    {
        case 1:
            HoraInicio = 6;
            HoraFin = 15;
            horasDisponiblesPorDia = 8.45;
            break;
        case 2:
            HoraInicio = 15;
            HoraFin = 24;
            horasDisponiblesPorDia = 7.45;
            break;
        case 3:
            HoraInicio = 0;
            HoraFin = 5;
            horasDisponiblesPorDia = 5.5;
            break;
        default:
            return "-- Invalid shift value";
    }

    int cantidadMaquinas = Machine_IDs.Split(',').Select(e => e.Trim()).Count();

    string query = string.Format(@"
        SELECT
            DATEPART(WEEK, Hora) - DATEPART(WEEK, DATEFROMPARTS(YEAR(Hora), MONTH(Hora), 1)) + 1 AS [Month Week],
            SUM(Request) AS Request,
            SUM(Produced) AS Produced,
            SUM(Variation) AS Variation,
            SUM(EFF) AS EFF,
            SUM(Scrap) AS Scrap,
            SUM(Ippm) AS Ippm,
            ROUND(SUM(Utilization) / 60, 2) AS [Utilization Mins],
            CONCAT(ROUND(SUM(Utilization) / 3600 / ({0} * {1} * 5) * 100, 2), '%') AS [Utilization %]
        FROM ShopFloor.dbo.ModbusMachineHistory
        WHERE Hora BETWEEN '{2}' AND '{3}'
          AND MachineID IN ({4})
          AND DATEPART(HOUR, Hora) BETWEEN {5} AND {6}
        GROUP BY
            DATEPART(WEEK, Hora) - DATEPART(WEEK, DATEFROMPARTS(YEAR(Hora), MONTH(Hora), 1)) + 1
        ORDER BY [Month Week];",
        horasDisponiblesPorDia,
        cantidadMaquinas,
        FechaInicio.ToString("yyyy-MM-dd"),
        FechaFin.ToString("yyyy-MM-dd"),
        Machine_IDs,
        HoraInicio,
        HoraFin
    );

    return query;
}







    private static string ObtenerRangoHorario(int hora, int turno)
    {
        if (hora < 0 || hora > 23 || turno < 1 || turno > 3)
            return hora.ToString();

        // Excepciones especiales
        if (hora == 15 && turno == 1)
            return "03:00 PM - 03:30 PM";
        if (hora == 15 && turno == 2)
            return "03:45 PM - 04:00 PM";
        if (hora == 0 && turno == 3)
            return "12:45 AM - 01:00 AM";

        DateTime inicio;
        DateTime fin;

        if (turno == 1 || turno == 3)
        {
            inicio = new DateTime(1, 1, 1, hora, 0, 0);
            fin = inicio.AddHours(1);
        }
        else if (turno == 2)
        {
            if (hora >= 16 || hora == 0)
            {
                inicio = new DateTime(1, 1, 1, hora, 0, 0);
                fin = inicio.AddHours(1);
            }
            else
            {
                return "Horario no definido para esta combinación";
            }
        }
        else
        {
            return "Turno no válido";
        }

        string formato = "hh:mm tt";
        return inicio.ToString(formato) + " - " + fin.ToString(formato);
    }




</script>
