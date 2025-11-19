<%@ Page Language="C#" AutoEventWireup="true" %>

<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Automation & Innovation RFQ Management</title>
   <script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-900 text-white min-h-screen p-5">

    <!-- Encabezado -->
    <header class="bg-blue-600 text-white p-4 shadow">
        <h1 class="text-xl font-semibold">Automation & Innovation RFQ Management</h1>
    </header>

    <div class="flex">
        <!-- Menú lateral -->
        <aside class="w-full bg-white shadow-md p-4">
            <nav class="space-y-2">
                <a href="#" class="block text-blue-600 font-medium            <a href="#" class="block text-gray-700 hover:textn</a>
            </nav>
        </aside>

        <!-- Contenido principal -->
        <main class="flex-1 p-6">
           <h2 class="text-lg font-bold text-black mb-4">RFQs List:</h2>
            <div class="overflow-x-auto">
                <table class="min-w-full bg-white shadow rounded-lg">
                    <thead class="bg-gray-200 text-black">
                        <tr>
                            <th class="text-left px-4 py-2">ID</th>
                            <th class="text-left px-4 py-2">NetID</th>
                            <th class="text-left px-4 py-2">Status</th>
                            <th class="text-left px-4 py-2">Description</th>
                            <th class="text-left px-4 py-2">Costo Total</th>
                            <th class="text-left px-4 py-2">Vendor</th>
                            <th class="text-left px-4 py-2">Creation Date</th>
                        </tr>
                    </thead>
                    <tbody id="rfq-table" class="divide-y divide-gray-100"></tbody>
                </table>
            </div>

            <!-- Indicador de carga -->
            <div id="loading-overlay" class="fixed inset-0 bg-black bg-opacity-30 flex items-center justify-center z-40 hidden">
                <div class="bg-white p-4 rounded shadow text-center">
                    <div class="animate-spin h-6 w-6 border-4 border-blue-500 border-t-transparent rounded-full mx-auto mb-2"></div>
                    <p class="text-sm text-gray-700">Processing Request...</p>
                </div>
            </div>

            <!-- Modal de detalle RFQ -->
            <div id="rfq-detail" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 hidden">
                <div class="bg-white rounded-lg shadow-lg w-full max-w-4xl p-6 overflow-y-auto max-h-[90vh]">
                    <div class="flex justify-between items-center mb-4">
                        <h3 class="text-lg font-semibold">RFQ Detail</h3>
                        <button onclick="closeModal()" class="text-gray-500 hover:text-red-600 text-xl">&times;</button>
                    </div>

                    <div id="rfq-info" class="mb-4"></div>
                    <div class="flex justify-end space-x-2 mb-4">
                        <button id="btn-save" class="bg-green-600 hover:bg-green-700 text-white font-semibold px-4 py-2 rounded shadow">
                            Save
                        </button>
                        <button id="btn-delete" class="bg-red-600 hover:bg-red-700 text-white font-semibold px-4 py-2 rounded shadow">
                            Delete
                        </button>
                        <button onclick="closeModal()" class="bg-gray-300 hover:bg-gray-400 text-gray-800 font-semibold px-4 py-2 rounded shadow">
                            Exit
                        </button>

                        <button id= "btn-send" class="bg-blue-300 hover:bg-gray-400 text-gray-800 font-semibold px-4 py-2 rounded shadow">
                            Send RFQ
                        </button>
                    </div>

                    <!-- Campos adicionales -->
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
                        <!-- RFQ Number -->
                        <div>
                            <label for="rfq-number" class="block text-sm font-medium text-gray-700 mb-1">RFQ Number</label>
                            <input type="text" id="rfq-number" class="w-full border border-gray-300 rounded px-3 py-2" />
                        </div>

                        <!-- PO Number -->
                        <div>
                            <label for="po-number" class="block text-sm font-medium text-gray-700 mb-1">PO Number</label>
                            <input type="text" id="po-number" class="w-full border border-gray-300 rounded px-3 py-2" />
                        </div>

                        <!-- Status -->
                        <div>
                            <label for="rfq-status" class="block text-sm font-medium text-gray-700 mb-1">Status</label>
                            <select id="rfq-status" class="w-full border border-gray-300 rounded px-3 py-2">
                                <option>Pending</option>
                                <option>Requested to Financial Dept.</option>
                                <option>Requested To Buyer</option>
                                <option>RFQ in approval Process</option>
                                <option>P.O. Created</option>
                                <option>Delivered</option>
                            </select>
                        </div>
                    </div>

                    <h4 class="text-md font-semibold mb-2">Artículos</h4>
                    <div class="overflow-x-auto">
                        <table class="min-w-full bg-white shadow rounded-lg">
                            <thead class="bg-gray-200">
                                <tr>
                                    <th class="text-left px-4 py-2">Qty</th>
                                    <th class="text-left px-4 py-2">UM</th>
                                    <th class="text-left px-4 py-2">Part #</th>
                                    <th class="text-left px-4 py-2">Brand</th>
                                    <th class="text-left px-4 py-2">Model</th>
                                    <th class="text-left px-4 py-2">Description</th>
                                    <th class="text-left px-4 py-2">Unit Price</th>
                                    <th class="text-left px-4 py-2">Total Cost</th>
                                </tr>
                            </thead>
                            <tbody id="rfq-items" class="divide-y divide-gray-100"></tbody>
                        </table>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <!-- Script de lógica -->
    <script>
        const netid = 'jcordoba01';
        
            function formatCurrency(value, currency) {
            const formatter = new Intl.NumberFormat('es-MX', {
                minimumFractionDigits: 2,
                maximumFractionDigits: 2
            });

            return `$${formatter.format(value)} ${currency}`;
        }
        
        function getProgressWidth(status) {
            switch (status) {
                case 'Pending': return 16;
                case 'Requested to Financial Dept.': return 33;
                case 'Requested To Buyer': return 49;
                case 'RFQ in approval Process': return 65;
                case 'P.O. Created': return 80;
                case 'Delivered': return 100;
                default: return 16;
            }
        }

        function getProgressBarClass(status) {
            switch (status) {
                case 'Pending': return 'bg-red-500 text-black';
                case 'Requested to Financial Dept.': return 'bg-orange-400 text-black text-xs';
                case 'Requested To Buyer': return 'bg-yellow-400 text-black';
                case 'RFQ in approval Process': return 'bg-blue-400 text-white';
                case 'P.O. Created': return 'bg-teal-500 text-white';
                case 'Delivered': return 'bg-green-500 text-white';
                default: return 'bg-gray-400 text-black';
            }
        }
        function getTextColorClass(status) {
            switch (status) {
                case 'Pending':
                case 'Requested to Financial Dept.':
                case 'Requested To Buyer':
                    return 'text-black';
                default:
                    return 'text-white';
            }
        }



        function loadRFQs() {
            axios.post('/DP/AJAX/GetRFQ.aspx', {
                Netid: netid,
                operation: 0
            }).then(response => {
                const rfqs = response.data;
                const tbody = document.getElementById('rfq-table');
                tbody.innerHTML = '';
                rfqs.forEach(rfq => {
                    const row = document.createElement('tr');
                    row.className = "hover:bg-gray-50 cursor-pointer text-black";
                    row.innerHTML = `
                    <td class="px-4 py-2">AI${rfq.Id.toString().padStart(4, '0')}</td>
                    <td class="px-4 py-2">${rfq.Netid}</td> 
                    <td class="px-4 py-2 w-64">
                        <div class="w-full bg-gray-200 rounded h-6 overflow-hidden relative">
                            <!-- Barra de progreso -->
                            <div class="${getProgressBarClass(rfq.Status)} h-6 rounded transition-all duration-500 ease-in-out absolute top-0 left-0"
                                style="width: ${getProgressWidth(rfq.Status)}%">
                            </div>
                            <!-- Texto encima de la barra -->
                            <div class="relative z-10 h-6 flex items-center justify-center text-base font-semibold ${getTextColorClass(rfq.Status)}">
                            ${rfq.Status}
                            </div>
                        </div>
                    </td>
                    <td class="px-4 py-2">${rfq.rfqDescription}</td>
                    <td class="px-4 py-2">${formatCurrency(rfq.T_Price, rfq.Currency)}</td>
                    <td class="px-4 py-2">${rfq.Vendor}</td>
                    <td class="px-4 py-2">${rfq.D_Created}</td>
                    `;

                    row.onclick = () => showRFQDetail(rfq.Id);
                    tbody.appendChild(row);
                });
            }).catch(error => {
                console.error('Error al cargar RFQs:', error);
            });
        }

        
        let isLoading = false;

        function showLoading() {
            isLoading = true;
            document.getElementById('loading-overlay').classList.remove('hidden');
        }

        function hideLoading() {
            isLoading = false;
            document.getElementById('loading-overlay').classList.add('hidden');
        }
        
        
       const rfqCache = {}; // Caché en memoria

        function showRFQDetail(orderId) {
            if (isLoading) return; // Evita múltiples clics
            showLoading();

            // Si ya está en caché, usarlo directamente
            if (rfqCache[orderId]) {
                const rfq = rfqCache[orderId];
                const items = rfq.items;
                gPAR = rfq.PAR;
                gTcost = rfq.T_Price;

                document.getElementById('rfq-info').innerHTML = `
                    <p><strong>ID:</strong> ${rfq.Id}</p>
                    <p><strong>Description:</strong> ${rfq.rfqDescription}</p>
                    <p><strong>Vendor:</strong> ${rfq.Vendor}</p>
                    <p><strong>Creation Date:</strong> ${rfq.D_Created}</p>
                    <p><strong>Buyer:</strong> ${rfq.L1_buyer || rfq.L2_buyer}</p>
                    <p><strong>PAR:</strong> ${rfq.PAR}</p>
                    <p><strong>Total Cost:</strong> ${formatCurrency(rfq.T_Price, rfq.Currency)}</p>
                `;

                document.getElementById('rfq-number').value = rfq.RFQ_Number || '';
                document.getElementById('po-number').value = rfq.PO_Number || '';
                document.getElementById('rfq-status').value = rfq.Status || 'Pending';

                const itemsBody = document.getElementById('rfq-items');
                itemsBody.innerHTML = '';
                items.forEach(item => {
                    const row = document.createElement('tr');
                    row.className = "hover:bg-gray-100 cursor-pointer";
                    row.onclick = () => {
                        if (item.Link && item.Link.trim() !== "") {
                            window.open(item.Link, '_blank');
                        }
                    };
                    row.innerHTML = `
                        <td class="px-4 py-2">${item.Qty}</td>
                        <td class="px-4 py-2">${item.UM}</td>
                        <td class="px-4 py-2">${item.Part_Num}</td>
                        <td class="px-4 py-2">${item.Brand}</td>
                        <td class="px-4 py-2">${item.Model}</td>
                        <td class="px-4 py-2">${item.Description}</td>
                        <td class="px-4 py-2">${formatCurrency(item.U_Price, rfq.Currency)}</td>
                        <td class="px-4 py-2">${formatCurrency(item.T_Price, rfq.Currency)}</td>
                    `;
                    itemsBody.appendChild(row);
                });

                document.getElementById('rfq-detail').classList.remove('hidden');
                hideLoading();
                return;
            }

            // Si no está en caché, llamar al webservice
            axios.post('/DP/AJAX/GetRFQ.aspx', {
                Netid: netid,
                operation: 1,
                Order_ID: orderId
            }).then(response => {
                const rfq = response.data;
                rfqCache[orderId] = rfq; // Guardar en caché
                const items = rfq.items;
                gPAR = rfq.PAR;

                document.getElementById('rfq-info').innerHTML = `
                    <p><strong>ID:</strong> ${rfq.Id}</p>
                    <p><strong>Description:</strong> ${rfq.rfqDescription}</p>
                    <p><strong>Vendor:</strong> ${rfq.Vendor}</p>
                    <p><strong>Creation Date:</strong> ${rfq.D_Created}</p>
                    <p><strong>Buyer:</strong> ${rfq.L1_buyer || rfq.L2_buyer}</p>
                    <p><strong>PAR:</strong> ${rfq.PAR}</p>
                    <p><strong>Total Cost:</strong> ${formatCurrency(rfq.T_Price, rfq.Currency)}</p>
                `;

                document.getElementById('rfq-number').value = rfq.RFQ_Number || '';
                document.getElementById('po-number').value = rfq.PO_Number || '';
                document.getElementById('rfq-status').value = rfq.Status || 'Pending';

                const itemsBody = document.getElementById('rfq-items');
                itemsBody.innerHTML = '';
                items.forEach(item => {
                    const row = document.createElement('tr');
                    row.className = "hover:bg-gray-100 cursor-pointer";
                    row.onclick = () => {
                        if (item.Link && item.Link.trim() !== "") {
                            window.open(item.Link, '_blank');
                        }
                    };
                    row.innerHTML = `
                        <td class="px-4 py-2">${item.Qty}</td>
                        <td class="px-4 py-2">${item.UM}</td>
                        <td class="px-4 py-2">${item.Part_Num}</td>
                        <td class="px-4 py-2">${item.Brand}</td>
                        <td class="px-4 py-2">${item.Model}</td>
                        <td class="px-4 py-2">${item.Description}</td>
                        <td class="px-4 py-2">${formatCurrency(item.U_Price, rfq.Currency)}</td>
                        <td class="px-4 py-2">${formatCurrency(item.T_Price, rfq.Currency)}</td>
                    `;
                    itemsBody.appendChild(row);
                });

                document.getElementById('rfq-detail').classList.remove('hidden');
            }).catch(error => {
                console.error('Error al cargar detalle de RFQ:', error);
            }).finally(() => {
                hideLoading();
            });
        }



        function closeModal() {
            document.getElementById('rfq-detail').classList.add('hidden');
            gPAR = '';
            gTcost = '';
        }

       

        document.getElementById('btn-save').onclick = function () {
            showLoading();
            const orderId = document.getElementById('rfq-info').querySelector('p strong')?.nextSibling?.textContent?.trim();
            const rfqNumber = document.getElementById('rfq-number').value;
            const poNumber = document.getElementById('po-number').value;
            const status = document.getElementById('rfq-status').value;

            if (!orderId) {
                console.error("No se encontró el Order_ID.");
                return;
            }

            const payload = {
                Netid: netid,
                Order_ID: orderId,
                operation: 2,
                Status: status,
                RFQ_Number: rfqNumber,
                PO_Number: poNumber
            };

            showLoading(); // Opcional: muestra el spinner

           axios.post('/DP/AJAX/GetRFQ.aspx', payload)
            .then(response => {
                console.log("RFQ liberada correctamente:", response.data);
                alert("La RFQ ha sido liberada exitosamente.");
                closeModal();
                rfqCache[orderId].Status = status;
                rfqCache[orderId].RFQ_Number = rfqNumber;
                rfqCache[orderId].PO_Number = poNumber;
            })
            .catch(error => {
                console.error("Error al liberar RFQ:", error);
                alert("Ocurrió un error al liberar la RFQ.");
            })
            .finally(() => {
                hideLoading(); // Oculta el spinner

                // ⏱️ Pausa de 250ms antes de ejecutar loadRFQs
                setTimeout(() => {
                    loadRFQs();
                }, 250);
            });

        };

        document.getElementById('btn-delete').onclick = function () {
            showLoading();
            const orderId = document.getElementById('rfq-info').querySelector('p strong')?.nextSibling?.textContent?.trim();

            if (!orderId) {
                console.error("No se encontró el Order_ID.");
                return;
            }

            const payload = {
                Netid: netid,
                Order_ID: orderId,
                operation: 4
            };

            showLoading(); // Opcional: muestra el spinner

            axios.post('/DP/AJAX/GetRFQ.aspx', payload)
                .then(response => {
                    console.log("RFQ Eliminada correctamente:", response.data);
                    alert("La RFQ ha sido Eliminada.");
                    closeModal();
                })
                .catch(error => {
                    console.error("Error al Eliminar RFQ:", error);
                    alert("Ocurrió un error al Eliminar la RFQ.");
                })
                .finally(() => {
                    hideLoading(); // Oculta el spinner
                    // ⏱️ Pausa de 250ms antes de ejecutar loadRFQs
                setTimeout(() => {
                    loadRFQs();
                }, 250);
                });
        };

         let gPAR = '';
         let gTcost = '';

         document.getElementById('btn-send').onclick = function () {
            showLoading();
            const orderId = document.getElementById('rfq-info').querySelector('p strong')?.nextSibling?.textContent?.trim();
            const rfqNumber = document.getElementById('rfq-number').value;
            const poNumber = document.getElementById('po-number').value;
            const status = document.getElementById('rfq-status').value;

            if (!orderId) {
                console.error("No se encontró el Order_ID.");
                return;
            }

            const payload = {
                Netid: netid,
                Order_ID: orderId,
                operation: 3,
                Status: status,
                RFQ_Number: rfqNumber,
                PO_Number: poNumber,
                PAR: gPAR,
                T_Price: gTcost
            };

            showLoading(); // Opcional: muestra el spinner

            axios.post('/DP/AJAX/GetRFQ.aspx', payload)
                .then(response => {
                    console.log("RFQ liberada correctamente:", response.data);                    
                    alert("La RFQ ha sido liberada exitosamente.");
                    closeModal();
                    
                })
                .catch(error => {
                    console.error("Error al liberar RFQ:", error);
                    alert("Ocurrió un error al liberar la RFQ.");
                })
                .finally(() => {
                    hideLoading(); // Oculta el spinner
                });
        };
        window.onload = loadRFQs;
    </script>
</body>
</html>
