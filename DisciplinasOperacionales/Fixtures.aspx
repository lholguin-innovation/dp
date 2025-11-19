<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Web.Services" %>

<!DOCTYPE html>
<html>
<head>
    <title>Fixture Catalog</title>
    <meta charset="utf-8" />
    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            background-color: #f0f2f5;
            padding: 20px;
        }
        .container {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 0 10px #ccc;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 15px;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 8px;
        }
        th {
            background-color: #007acc;
            color: white;
            text-align: left;
        }
        td input {
            width: 100%;
            border: none;
            background: transparent;
        }
        .btn {
            padding: 10px 20px;
            margin-right: 10px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
        .btn-save { background-color: #4CAF50; color: white; }
        .btn-cancel { background-color: #f44336; color: white; }
        .btn-refresh { background-color: #2196F3; color: white; }
        .btn-add {
            background-color: #FF9800;
            color: white;
            margin-bottom: 10px;
            display: inline-block;
        }

        #fixturesTable td:nth-child(2), /* FixtureName */
        #fixturesTable th:nth-child(2),
        #fixturesTable td:nth-child(5), /* Model */
        #fixturesTable th:nth-child(5),
        #fixturesTable td:nth-child(10), /* Part_Number */
        #fixturesTable th:nth-child(10) {
            min-width: 200px;
            max-width: 500px;
            word-wrap: break-word;
        }
        .table-wrapper {
            overflow-x: auto;
            max-width: 100%;
        }

    </style>
</head>
<body>
    <div class="container">
        <h2>Fixture Catalog</h2>
        <div class="table-wrapper">
            <button class="btn btn-add" onclick="addRow()">Add New Line</button>
            <table id="fixturesTable">
                <thead>
                    <tr id="tableHeader"></tr>
                </thead>
                <tbody id="tableBody"></tbody>
            </table>
        </div>
        
        <button class="btn btn-save" onclick="guardar()">Save</button>
        <button class="btn btn-cancel" onclick="cancelar()">Cancel</button>
        <button class="btn btn-refresh" onclick="cargarDatos()">Refresh</button>
    </div>

    <script>
        function cargarDatos() {
                showLoading();
                fetch("Fixtures.aspx/GetFixtures", {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({})
                })
                .then(res => res.json())
                .then(data => {
                    const rows = JSON.parse(data.d);
                    const header = document.getElementById("tableHeader");
                    const body = document.getElementById("tableBody");
                    header.innerHTML = "";
                    body.innerHTML = "";

                    if (rows.length > 0) {
                        Object.keys(rows[0]).forEach(key => {
                            const th = document.createElement("th");
                            th.textContent = key;
                            header.appendChild(th);
                        });

                        rows.forEach(row => {
                            const tr = document.createElement("tr");
                            Object.entries(row).forEach(([key, value], index) => {
                                const td = document.createElement("td");
                                if (key === "Id") {
                                    td.textContent = value;
                                } else {
                                    td.innerHTML = `<input type="text" value="${value}" />`;
                                }
                                tr.appendChild(td);
                            });
                            body.appendChild(tr);
                        });
                    }
                })
                .catch(err => {
                    console.error(err);
                    alert("Error al cargar los datos.");
                })
                .finally(() => hideLoading());
            }


        function addRow() {
            const header = document.getElementById("tableHeader");
            const body = document.getElementById("tableBody");
            const tr = document.createElement("tr");
            for (let i = 0; i < header.children.length; i++) {
                const key = header.children[i].textContent;
                const td = document.createElement("td");
                if (key === "Id") {
                    td.textContent = "Nuevo";
                } else {
                    td.innerHTML = `<input type="text" />`;
                }
                tr.appendChild(td);
            }
            body.appendChild(tr);
        }

        function guardar() {
            showLoading();
            const rows = document.querySelectorAll("#fixturesTable tbody tr");
            const data = [];
            const headers = Array.from(document.querySelectorAll("#tableHeader th")).map(th => th.textContent);

            rows.forEach(row => {
                const cells = row.cells;
                const rowData = {};
                headers.forEach((key, i) => {
                    if (i === 0) {
                        rowData[key] = cells[i].textContent;
                    } else {
                        const input = cells[i].querySelector("input");
                        rowData[key] = input ? input.value : "";
                    }
                });
                data.push(rowData);
            });

            fetch("Fixtures.aspx/GuardarFixtures", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ fixtures: data })
            })
            .then(res => res.json())
            .then(result => {
                alert("Cambios guardados correctamente.");
                cargarDatos();
            })
            .catch(err => {
                console.error(err);
                alert("Error al guardar los datos.");
            })
            .finally(() => hideLoading());
        }


        function cancelar() {
            showLoading();
            setTimeout(() => {
                location.reload();
            }, 500); // Pequeño delay para mostrar el modal
        }

        function showLoading() {
            document.getElementById("loadingModal").style.display = "block";
        }

        function hideLoading() {
            document.getElementById("loadingModal").style.display = "none";
        }


        window.onload = cargarDatos;
    </script>

    <script runat="server">
        [WebMethod]
        public static string GetFixtures()
        {
            string connStr = "Server=mxchlac-sql04;Database=LAIMS;User Id=sqlIIT;Password=Le@r2025!iitdata;MultipleActiveResultSets=True;";
            DataTable dt = new DataTable();
           
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                SqlDataAdapter da = new SqlDataAdapter(@"SELECT TOP (1000) [Id]
                                                        ,[FixtureName]
                                                        ,[Fixture]
                                                        ,id_Carline
                                                        ,[Model]
                                                        ,[Componente]
                                                        ,[Item]
                                                        ,isnull(Program_Time,0) As Program_Time
                                                        ,[Sewing_time]
                                                        ,[Part_Number]
                                                        ,[PCS_Fixture]
                                                        ,[Cycles_To_30]
                                                        ,[Backtacks]
                                                        ,[Stitches]
                                                        ,[RPM_Low]
                                                        ,[RPM_High]
                                                        ,[PPP]
                                                        ,[Needle]
                                                        ,[Bobbin]
                                                        ,[FixturesPerBobbin]
                                                    FROM [Catalogos].[dbo].[Cat_Fixtures] A", conn);
                da.Fill(dt);
            }

            var rows = new List<Dictionary<string, string>>();
            foreach (DataRow dr in dt.Rows)
            {
                var row = new Dictionary<string, string>();
                foreach (DataColumn col in dt.Columns)
                {
                    row[col.ColumnName] = dr[col].ToString();
                }
                rows.Add(row);
            }

            return Newtonsoft.Json.JsonConvert.SerializeObject(rows);
        }

        [WebMethod]
        public static string GuardarFixtures(List<Dictionary<string, string>> fixtures)
        {
            string connStr = "Server=mxchlac-sql04;Database=LAIMS;User Id=sqlIIT;Password=Le@r2025!iitdata;MultipleActiveResultSets=True;";
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                foreach (var row in fixtures)
                {
                    string id = row["Id"];
                    if (id == "Nuevo")
                    {
                        string insertQuery = @"INSERT INTO [Catalogos].[dbo].[Cat_Fixtures]
                            ([FixtureName],[id_Carline],[Componente],[Model],[Item],[Fixture],
                             [Sewing_time],[Part_Number],[PCS_Fixture],[Cycles_To_30],[Backtacks],[Stitches],
                             [RPM_Low],[RPM_High],[PPP],[Needle],[Bobbin], [Program_Time])
                            VALUES
                            (@FixtureName,@id_Carline,@Componente,@Model,@Item,@Fixture,
                             @Sewing_time,@Part_Number,@PCS_Fixture,@Cycles_To_30,@Backtacks,@Stitches,
                             @RPM_Low,@RPM_High,@PPP,@Needle,@Bobbin, @Program_Time)";
                        using (SqlCommand cmd = new SqlCommand(insertQuery, conn))
                        {
                            foreach (var key in row.Keys)
                            {
                                if (key == "Id") continue;

                                var value = string.IsNullOrWhiteSpace(row[key]) ? DBNull.Value : (object)row[key];
                                cmd.Parameters.AddWithValue("@" + key, value);
                            }

                            cmd.ExecuteNonQuery();
                        }
                    }
                    else
                    {
                        string updateQuery = @"UPDATE [Catalogos].[dbo].[Cat_Fixtures] SET [FixtureName] = @FixtureName, 
                            [id_Carline]=@id_Carline,[Componente]=@Componente,[Model]=@Model,[Item]=@Item,[Fixture]=@Fixture,
                            [Sewing_time]=@Sewing_time,[Part_Number]=@Part_Number,[PCS_Fixture]=@PCS_Fixture,
                            [Cycles_To_30]=@Cycles_To_30,[Backtacks]=@Backtacks,[Stitches]=@Stitches,
                            [RPM_Low]=@RPM_Low,[RPM_High]=@RPM_High,[PPP]=@PPP,[Needle]=@Needle,[Bobbin]=@Bobbin, [Program_Time] = @Program_Time
                            WHERE Id=@Id";
                        using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                        {
                            foreach (var key in row.Keys)
                            {
                                if (key == "Id") continue;

                                var value = string.IsNullOrWhiteSpace(row[key]) ? DBNull.Value : (object)row[key];
                                cmd.Parameters.AddWithValue("@" + key, value);
                            }
                            cmd.Parameters.AddWithValue("@Id", id);
                            cmd.ExecuteNonQuery();
                        }
                    }
                }
            }
            return "OK";
        }
    </script>

    <!-- Modal de carga -->
    <div id="loadingModal" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%;
        background-color:rgba(0,0,0,0.5); z-index:9999; text-align:center; padding-top:200px;">
        <div style="background:white; padding:20px 40px; border-radius:10px; display:inline-block; font-size:18px;">
            Loading, please wait...
        </div>
    </div>

</body>
</html>
