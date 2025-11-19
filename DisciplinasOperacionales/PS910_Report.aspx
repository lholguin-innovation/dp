<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Module Report Viewer</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f2f2f2;
            color: #2c3e50;
            margin: 0;
            padding: 0;
        }

        header {
            background-color: #1a2b4c;
            color: white;
            padding: 20px;
            text-align: center;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        main {
            padding: 30px;
            max-width: 1500px;
            margin: auto;
        }

        .form-group {
            margin-bottom: 20px;
        }

        label {
            display: block;
            margin-bottom: 6px;
            font-weight: 600;
        }

        select, input[type="date"] {
            width: 100%;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 15px;
        }

        button {
            background-color: #1a2b4c;
            color: white;
            padding: 12px 20px;
            font-size: 16px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }

        button:hover {
            background-color: #2c3e70;
        }

        h3 {
            margin-top: 40px;
            color: #1a2b4c;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
            background-color: white;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        }

        th, td {
            border: 1px solid #ddd;
            padding: 10px;
            text-align: left;
        }

        th {
            background-color: #1a2b4c;
            color: white;
        }

        .report-section {
            margin-top: 30px;
        }
        .form-row {
        display: flex;
        flex-wrap: wrap;
        gap: 20px;
        align-items: flex-end;
        margin-bottom: 30px;
    }

    .form-group {
        display: flex;
        flex-direction: column;
        min-width: 150px;
        flex: 1;
    }

    .form-group label {
        font-weight: 600;
        margin-bottom: 5px;
    }

    .form-group select,
    .form-group input[type="date"] {
        padding: 8px;
        font-size: 14px;
        border: 1px solid #ccc;
        border-radius: 4px;
    }

    .form-row button {
        height: 40px;
        align-self: center;
        padding: 0 20px;
        background-color: #1a2b4c;
        color: white;
        border: none;
        border-radius: 6px;
        font-size: 15px;
        cursor: pointer;
        white-space: nowrap;
    }

    .form-row button:hover {
        background-color: #2c3e70;
    }

    /* Responsive para pantallas pequeÃ±as */
    @media (max-width: 768px) {
        .form-row {
            flex-direction: column;
            align-items: stretch;
        }

        .form-group {
            width: 100%;
        }

        .form-row button {
            width: 100%;
            margin-top: 10px;
        }
    }
    .totals-row {
        background-color: #f0f0f0c0;
        font-weight: bold;
    }
    /* Modal cubre toda la pantalla */
    .modal {
    display: none;
    position: fixed;
    z-index: 9999;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    background-color: rgba(0, 0, 0, 0.6); /* fondo semi-transparente */
    display: flex;
    align-items: center;
    justify-content: center;
    }

    /* Contenido centrado */
    .modal-content {
    text-align: center;
    color: white;
    }

    /* Spinner circular */
    .spinner {
    border: 8px solid #f3f3f3;
    border-top: 8px solid #3498db;
    border-radius: 50%;
    width: 60px;
    height: 60px;
    animation: spin 1s linear infinite;
    margin: 0 auto 10px;
    }

    @keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
    }

    </style>
</head>
<body>

    <header>
        <h1>Module Report Viewer</h1>
    </header>

    <main>
<div class="form-row">
    <div class="form-group">
        <label for="plant">Select Plant:</label>
        <select id="plant">
           <option value="1">Ascension</option>
            <option value="2">Alamedas</option>
            <option value="3">Paquime</option>
            <option value="4">Juarez Warehouse</option>
            <option value="5">Fuentes</option>
            <option value="6">San Lorenzo</option>
            <option value="7">Rio Bravo 1</option>
            <option value="8">La Cuesta</option>
            <option value="9">Zaragosa</option>
            <option value="10">Pedro Meoqui</option>
            <option value="11">Villa Ahumada</option>
            <option value="12">San Felipe</option>
            <option value="13">Panzacola 2</option>
        </select>
    </div>

    <div class="form-group">
        <label for="module">Select Module:</label>
        <select id="module" multiple> 
        </select>
    </div>

    <div class="form-group">
        <label for="machine">Select Machine:</label>
        <select id="machine"></select>
    </div>

    <div class="form-group">
        <label for="shift">Select Shift:</label>
        <select id="shift">
            <option value="1" selected>1</option>
            <option value="2">2</option>
            <option value="3">3</option>
             <option value="0">All</option>
        </select>
    </div>

    <div class="form-group">
        <label for="date">Start Date:</label>
        <input type="date" id="date" onchange="validateDates()">      
    </div>

    <div class="form-group">
        <label for="endDate">End Date:</label>
        <input type="date" id="endDate" onchange="validateDates()">        
    </div>

    <div class="form-group">
        <label for="groupBy">Group By:</label>
        <select id="groupBy">
            <option value="hour" selected>Hour X Hour</option>
            <option value="day">Day</option>
            <option value="week">Week</option>
            <option value="month">Month</option>
            <option value="year">Year</option>
            <option value="machine">Machine</option>
            <option value="module">Module</option>
        </select>
    </div>
    <div class="form-group" style="display: inline-block; vertical-align: top; margin-top: 24px;">
        <button onclick="getReport()">Get Report</button>
    </div>
</div>

        <div id="reportContainer" class="report-section"></div>
        <!-- Modal -->
        <div id="loadingModal" class="modal">
        <div class="modal-content">
            <div class="spinner"></div>
            <p>Procesando, por favor espera...</p>
        </div>
        </div>
    </main>

<script src="https://code.jquery.com/jquery-3.7.1.js" integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4=" crossorigin="anonymous"></script>
    <script>
        
        function validateDates() {
            const start = document.getElementById("date").value;
            const end = document.getElementById("endDate").value;
            if (end < start) {
                alert("End date cannot be earlier than start date.");
                document.getElementById("endDate").value = start;
            }
        }

        function showLoading() {
            document.getElementById("loadingModal").style.display = "flex";
        }
        // Ocultar el modal
        function hideLoading() {
            document.getElementById("loadingModal").style.display = "none";
        }
        const machine_IDs = {};
        const machine_Names = {};

        document.getElementById('plant').addEventListener('change', function () {
            showLoading();
            const idPlant = this.value;
            const Operation = 0;

            fetch('/DP/AJAX/getmodules_edit.aspx', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ idPlant, Operation })
            })
            .then(res => res.json())
            .then(data => {
                const moduleSelect = document.getElementById('module');
                moduleSelect.innerHTML = '';
                const machineSelect = document.getElementById('machine');
                machineSelect.innerHTML = '';

                data.modules.forEach(mod => {
                    const opt = document.createElement('option');
                    opt.value = mod.idModule;
                    opt.textContent = mod.Alias;
                    moduleSelect.appendChild(opt);

                    machine_IDs[mod.idModule] = mod.machine_ids;
                    machine_Names[mod.idModule] = mod.Machines;
                });

                // Disparar el evento de cambio manualmente para cargar las mÃ¡quinas del primer mÃ³dulo
                moduleSelect.dispatchEvent(new Event('change'));
            })
            .finally(() => hideLoading());
        });

       document.getElementById('module').addEventListener('change', function () {
            const selectedModuleId = this.value;
            const machineSelect = document.getElementById('machine');
            machineSelect.innerHTML = '';

            const machines = machine_Names[selectedModuleId] || [];

            // Agregar opciÃ³n "All" primero
            const allOption = document.createElement('option');
            allOption.value = 0;
            allOption.textContent = 'All';
            machineSelect.appendChild(allOption);

            // Agregar las demÃ¡s mÃ¡quinas
            machines.forEach(name => {
                const opt = document.createElement('option');
                // Extrae el nÃºmero antes del guion
                const valuePart = name.split('-')[0].trim(); 
                opt.value = valuePart;
                opt.textContent = name;
                machineSelect.appendChild(opt);
            });

        });

         const dateInput = document.getElementById('date');
         const dateOutput = document.getElementById('endDate');

        // Establecer fecha actual por defecto
        const today = new Date().toISOString().split('T')[0];
        dateInput.value = today;
        dateOutput.value = today;

       function getReport() {
            showLoading();
            const idPlant = document.getElementById('plant').value;
            var idModule = document.getElementById('module').value;
            var lstModules=[];
            var lstMachines=[];
            $('#module option:selected').each(function() {
                lstModules.push($(this).val())
                lstMachines.push(machine_IDs[$(this).val()]);
            });
            idModule=lstModules.join(",");
          //  const idMachines = document.getElementById('machine').value == 0 ? machine_IDs[idModule] : 
        //    document.getElementById('machine').value;
            const idMachines = lstMachines.join(",");
            console.log(idMachines);
            const Turno = document.getElementById('shift').value;
            const dateInput = document.getElementById('date').value;
            const dateOutput = document.getElementById('endDate').value;
            const groupBy = document.getElementById('groupBy').value;
            const Operation = 1;

            let FechaInicio = '';
            let FechaFin = '';

            FechaInicio = dateInput;
            FechaFin = dateOutput;

            const params = { idPlant, idModule, idMachines, Turno, FechaInicio, FechaFin, Operation, groupBy };

            fetch('/DP/AJAX/GetModules_edit.aspx', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(params)
            })
            .then(res => res.json())
            .then(data => {
                createTables(data);
            })
            .finally(() => hideLoading());
        }


        function createTables(data) {
            const container = document.getElementById('reportContainer');
            container.innerHTML = '';

            container.appendChild(createTable('General Module Report', data.report));

            /*for (const machineId in data.machines) {
                const machineData = data.machines[machineId];
                container.appendChild(createTable(`Machine ${machineId} Report`, machineData));
            }*/
        }
        function createTable(title, tableData) {
            const section = document.createElement('div');
            const heading = document.createElement('h3');
            heading.textContent = title;
            section.appendChild(heading);

            const table = document.createElement('table');
            const thead = document.createElement('thead');
            const tbody = document.createElement('tbody');

            const headerRow = document.createElement('tr');
            const keys = Object.keys(tableData[0]);
            keys.forEach(key => {
                const th = document.createElement('th');
                th.textContent = key;
                headerRow.appendChild(th);
            });
            thead.appendChild(headerRow);

            // Inicializar acumuladores
            const totals = {};
            const counts = {}; // para promedio en "Utilization %"
            keys.forEach(key => {
                totals[key] = 0;
                counts[key] = 0;
            });

            tableData.forEach(row => {
                const tr = document.createElement('tr');
                keys.forEach(key => {
                    const td = document.createElement('td');
                    td.textContent = row[key];
                    tr.appendChild(td);

                    const isDateTime = key.toLowerCase().includes('fecha') ||
                                    key.toLowerCase().includes('hour') ||
                                    key.toLowerCase().includes('time') ||
                                    key.toLowerCase().includes('week') ||
                                    key.toLowerCase().includes('date');

                    const val = parseFloat(row[key]);
                    if (!isNaN(val) && !isDateTime) {
                        totals[key] += val;
                        counts[key]++;
                    }
                });
                tbody.appendChild(tr);
            });

            // Crear fila de totales
            const totalRow = document.createElement('tr');
            totalRow.classList.add('totals-row');
            let Request = 0;
            let Produced = 0;

            keys.forEach(key => {
                const td = document.createElement('td');
                const isDateTime = key.toLowerCase().includes('fecha') ||
                                key.toLowerCase().includes('hour') ||
                                key.toLowerCase().includes('time') ||
                                key.toLowerCase().includes('week') ||
                                key.toLowerCase().includes('date');
                

                if (!isDateTime && !isNaN(totals[key])) {
                    if (key === "Utilization %") {
                        // Calcular promedio
                        const avg = totals[key] / counts[key];
                        td.textContent = avg.toFixed(2) + '%';
                    } else if (key === "Request"){
                        Request = totals[key].toFixed(2);
                        td.textContent = totals[key].toFixed(2);
                    } else if (key === "Produced"){
                        Produced = totals[key].toFixed(2);
                        td.textContent = totals[key].toFixed(2);
                    } else if (key === "Efficiency"){
                        const calc = Request > 0 ? (Produced / Request) * 100 : 0;
                        td.textContent = calc.toFixed(2) + '%';
                     } else {
                        td.textContent = totals[key].toFixed(2);
                    }
                } else {
                    td.textContent = key === keys[0] ? 'Totals' : '';
                }
                td.style.fontWeight = 'bold';
                totalRow.appendChild(td);
            });

            tbody.appendChild(totalRow);
            table.appendChild(thead);
            table.appendChild(tbody);
            section.appendChild(table);

            return section;
        }
        hideLoading();
    </script>

</body>
</html>