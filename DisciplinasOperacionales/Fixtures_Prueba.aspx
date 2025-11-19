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

        
        #fixturesTable td:nth-child(4), /* Model */
        #fixturesTable th:nth-child(4),
        #fixturesTable td:nth-child(11), /* Part_Number */
        #fixturesTable th:nth-child(11) {
            min-width: 200px;
            max-width: 300px;
            word-wrap: break-word;
        }
        .table-wrapper {
            overflow-x: auto;
            max-width: 100%;
        }

    
.btn-edit { background-color: #9C27B0; color: white; }
.tab-container { margin-top: 20px; }
.tab-header { display: flex; gap: 10px; margin-bottom: 10px; }
.tab-header button { padding: 8px 16px; border: none; border-radius: 5px; cursor: pointer; background-color: #ccc; }
.tab-header button.active { background-color: #007acc; color: white; }
.tab-content { display: none; padding: 20px; background: white; border-radius: 10px; box-shadow: 0 0 10px #ccc; }
.tab-content.active { display: block; }

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

<div class="tab-container">
  <div class="tab-header" id="tabHeaders"></div>
  <div id="tabContents"></div>
</div>

        
        <button class="btn btn-save" onclick="guardar()">Save</button>
        <button class="btn btn-cancel" onclick="cancelar()">Cancel</button>
        <button class="btn btn-refresh" onclick="cargarDatos()">Refresh</button>
    </div>

    <script>
        
        var fixtureCache = {};
        

            function cacheFixtures(rows) {
                fixtureCache = {}; // Reinicia el cache cada vez que se cargan nuevos datos

                for (var i = 0; i < rows.length; i++) {
                    var row = rows[i];
                    var id = row["Id"];
                    fixtureCache[id] = row;
                }
            }

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
                            cacheFixtures(rows); // ✅ Guarda los datos en memoria
                            const editTh = document.createElement("th");
                            editTh.textContent = "Edit";
                            header.insertBefore(editTh, header.children[1]);

                            Object.keys(rows[0]).forEach(key => {
                                                        const th = document.createElement("th");
                                                        th.textContent = key;
                                                        header.appendChild(th);
                                                    });

                             rows.forEach(function(row) {
                                const tr = document.createElement("tr");

                                const editTd = document.createElement("td");
                                editTd.innerHTML = "<button class='btn btn-edit' onclick='openEditTab(" + row["Id"] + ")'>Edit</button>";
                                tr.appendChild(editTd); // ✅ ahora sí existe 'tr'

                                Object.entries(row).forEach(function(entry) {
                                    var key = entry[0];
                                    var value = entry[1];
                                    var td = document.createElement("td");

                                    if (key === "Id") {
                                        td.textContent = value;
                                    } else {
                                        td.innerHTML = "<input type='text' value='" + value + "' />";
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
                    td.innerHTML = "<input type='text' />";
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

            const editTd = document.createElement("td");
            editTd.innerHTML = "<button class='btn btn-edit' onclick='openEditTab(" + row["Id"] + ")'>Edit</button>";
            tr.insertBefore(editTd, tr.children[1]);

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
    
let carlinesCache = [];
loadCarlinesOnce();

function loadCarlinesOnce() {
  if (carlinesCache.length === 0) {
    fetch("Fixtures_Prueba.aspx/GetCarlines", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({})
    })
    .then(res => res.json())
    .then(data => carlinesCache = JSON.parse(data.d));
  }
}


function openEditTab(id) {
        if (document.getElementById("tab-" + id)) return;

        var tabHeader = document.createElement("button");
        tabHeader.textContent = "Edit " + id;
        tabHeader.className = "active";
        tabHeader.onclick = function () {
            showTab(id);
        };
        document.getElementById("tabHeaders").appendChild(tabHeader);

        var tabContent = document.createElement("div");
        tabContent.id = "tab-" + id;
        tabContent.className = "tab-content active";
        tabContent.innerHTML = "<div id='form-" + id + "'>Loading...</div>";
        document.getElementById("tabContents").appendChild(tabContent);

        // ✅ Obtener datos desde el cache
        var fixture = fixtureCache[id];
        if (fixture) {
            var formHtml = generateEditForm(fixture);
            document.getElementById("form-" + id).innerHTML = formHtml;
            applyNumericValidation();
            populateCarlineDropdown(id, fixture.id_Carline);
        } else {
            document.getElementById("form-" + id).innerHTML = "<div class='error'>Fixture not found in cache.</div>";
        }
    }


function showTab(id) {
  document.querySelectorAll(".tab-content").forEach(tab => tab.classList.remove("active"));
  document.querySelectorAll(".tab-header button").forEach(btn => btn.classList.remove("active"));
  document.getElementById("tab-" + id + "").classList.add("active");
  document.querySelector(".tab-header button:contains('Edit " + id + "')").classList.add("active");
}

function generateEditForm(fixture) {
  return "<label>ID: " + fixture.Id + "</label><br/>" + "<label>Carline:</label>" + "<select id='ddlCarline-" + fixture.Id + "'></select><br/>" + "<label>OP_Num:</label>" + "<input type='text' class='numeric-only' id='opnum-" + fixture.Id + "' value='" + fixture.OP_Num + "' /><br/>" + "<label>Std_Seg:</label>" + "<input type='text' class='numeric-only' id='stdseg-" + fixture.Id + "' value='" + fixture.Std_Seg + "' /><br/>" + "<button onclick='saveChanges(" + fixture.Id + ")'>Save</button>" + "<button onclick='closeTab(" + fixture.Id + ")'>Cancel</button>" + "<button onclick='resetForm(" + fixture.Id + ")'>Reset</button>";
}

function populateCarlineDropdown(id, selectedId) {
  const ddl = document.getElementById("ddlCarline-" + id + "");
  ddl.innerHTML = carlinesCache.map(c =>
  "<option value='" + c.id + "' " + (c.id == selectedId ? "selected" : "") + ">" + c.Carline + "</option>"
).join("");
}

function applyNumericValidation() {
  document.querySelectorAll(".numeric-only").forEach(input => {
    input.addEventListener("input", function () {
      this.value = this.value.replace(/[^0-9.,]/g, "");
    });
  });
}

function saveChanges(id) {
  const data = {
    Id: id,
    id_Carline: document.getElementById("ddlCarline-" + id + "").value,
    OP_Num: document.getElementById("opnum-" + id + "").value,
    Std_Seg: document.getElementById("stdseg-" + id + "").value
  };
  fetch("Fixtures.aspx/UpdateFixture", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ fixture: data })
  })
  .then(() => cargarDatos());
}

function closeTab(id) {
  document.getElementById("tab-" + id + "").remove();
  document.querySelector(".tab-header button:contains('Edit " + id + "')").remove();
}

function resetForm(id) {
  openEditTab(id);
}

</script>

<script runat="server">

     [WebMethod]
        public static string GetCarlines()
        {
            string connStr = "Server=mxchlac-sql04;Database=LAIMS;User Id=sqlIIT;Password=Le@r2025!iitdata;MultipleActiveResultSets=True;";
            DataTable dt = new DataTable();
           
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                SqlDataAdapter da = new SqlDataAdapter("  Select id, CONCAT(Car_line, ' ', Program, ' ', Code) as Carline   FROM [Catalogos].[dbo].[Cat_Carlines]", conn);
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
        public static string GetFixtures()
        {
            string connStr = "Server=mxchlac-sql04;Database=LAIMS;User Id=sqlIIT;Password=Le@r2025!iitdata;MultipleActiveResultSets=True;";
            DataTable dt = new DataTable();
           
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                SqlDataAdapter da = new SqlDataAdapter("SELECT TOP 1000 * FROM [Catalogos].[dbo].[Cat_Fixtures]", conn);
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
                            ([FixtureName],id_Carline],[Componente],[Model],[OP_Num],[OP_Desc],[Std_Seg],[Item],[Fixture],
                             [Sewing_time],[Part_Number],[PCS_Fixture],[Cycles_To_30],[Backtacks],[Stitches],
                             [RPM_Low],[RPM_High],[PPP],[Needle],[Bobbin])
                            VALUES
                            (@FixtureName,@id_Carline,@Componente,@Model,@OP_Num,@OP_Desc,@Std_Seg,@Item,@Fixture,
                             @Sewing_time,@Part_Number,@PCS_Fixture,@Cycles_To_30,@Backtacks,@Stitches,
                             @RPM_Low,@RPM_High,@PPP,@Needle,@Bobbin)";
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
                            [id_Carline]=@id_Carline,[Componente]=@Componente,[Model]=@Model,[OP_Num]=@OP_Num,
                            [OP_Desc]=@OP_Desc,[Std_Seg]=@Std_Seg,[Item]=@Item,[Fixture]=@Fixture,
                            [Sewing_time]=@Sewing_time,[Part_Number]=@Part_Number,[PCS_Fixture]=@PCS_Fixture,
                            [Cycles_To_30]=@Cycles_To_30,[Backtacks]=@Backtacks,[Stitches]=@Stitches,
                            [RPM_Low]=@RPM_Low,[RPM_High]=@RPM_High,[PPP]=@PPP,[Needle]=@Needle,[Bobbin]=@Bobbin
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
