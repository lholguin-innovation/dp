<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Purchase Request</title>
    <script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .status-running { background-color: #16a34a; color: white; }
        .status-slow { background-color: #facc15; color: black; }
        .status-stopped { background-color: #dc2626; color: white; }
        .blink {
            animation: blink-animation 1s steps(5, start) infinite;
        }
        .status-neutral { background-color: #666565; color: white; }
        @keyframes blink-animation {
            to { visibility: hidden; }
        }
    </style>
</head>
<body class="bg-gray-900 text-white min-h-screen p-5">

  <div class="container mx-auto w-full p-6">
    <h1 class="text-3xl font-bold mb-6 text-center">Create Purchase Request</h1>

    <!-- Sección de radio buttons -->
    <div class="mb-6">
    <label class="block text-lg font-semibold mb-2">Does Exist a PAR for this RFQ?</label>
    <div class="flex space-x-4 mb-4">
        <label class="inline-flex items-center">
        <input type="radio" name="parExists" value="yes" class="form-radio text-blue-600" onclick="toggleParName(true)">
        <span class="ml-2">Yes</span>
        </label>
        <label class="inline-flex items-center">
        <input type="radio" name="parExists" value="no" class="form-radio text-blue-600" checked onclick="toggleParName(false)">
        <span class="ml-2">No</span>
        </label>
    </div>

    <!-- Textbox para el nombre del PAR -->
    <div id="parNameContainer" class="hidden">
        <label for="parName" class="block text-lg font-semibold mb-1">PAR Name <span class="text-red-500">*</span></label>
        <input type="text" id="parName" name="parName" class="border border-gray-300 rounded px-3 py-2 text-black" placeholder="Enter PAR Name">
    </div>
    </div>

    <!-- Dropdown para seleccionar el email del comprador -->
    <div class="mb-6">
    <label for="buyerEmail" class="block text-lg font-semibold mb-1">
        Buyer Email <span class="text-red-500">*</span>
    </label>

    <select id="buyerEmail" name="buyerEmail" class="border border-gray-300 rounded px-3 py-2 text-black">
        <option value="">Select a Buyer</option>
        <option value="MRojas@lear.com">Mario Rojas</option>
        <option value="BHernandezSierra@lear.com">Beatriz Sierra Hernandez</option>
    </select>
    </div>
    

    <!-- RFQ Description (obligatorio) -->
    <div class="mb-6">
      <label for="rfqDescription" class="block text-lg font-semibold mb-1">
        RFQ Description <span class="text-red-500">*</span>
      </label>
      <input type="text" id="rfqDescription" name="rfqDescription" required placeholder="Project, Usage Description for the RFQ"
             class="w-full px-4 py-2 rounded bg-gray-800 text-white border border-gray-600 focus:outline-none focus:ring-2 focus:ring-blue-500">
    </div>

    <!-- Vendor (opcional) -->
    <div class="mb-6">
      <label for="vendor" class="block text-lg font-semibold mb-1">Vendor</label>
      <input type="text" id="vendor" name="vendor" placeholder="Optional"
             class="w-full px-4 py-2 rounded bg-gray-800 text-white border border-gray-600 focus:outline-none focus:ring-2 focus:ring-blue-500">
    </div>

    <div id="orderContainer" class="space-y-4"></div>

    <div class="flex justify-center space-x-4 mt-6">
      <button id="checkButton" onclick="checkOrder()" class="bg-gray-400 text-white px-6 py-2 rounded hover:bg-gray-400">Check Order</button>
      <button id="submitButton" onclick="confirmSubmission()" class="bg-gray-400 text-white px-6 py-2 rounded hover:bg-gray-400" disabled>Submit</button>
      <button onclick="resetForm()" class="bg-gray-400 text-white px-6 py-2 rounded hover:bg-gray-500">Cancel</button>
    </div>
  </div>

  <!-- Modal -->
  <div id="modal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center hidden">
    <div class="bg-white p-6 rounded shadow-lg text-center text-black">
      <p id="modalMessage" class="text-lg font-semibold"></p>
      <button onclick="closeModal()" class="mt-4 bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">Cerrar</button>
    </div>
  </div>

    <script>
        let orderIndex = 0;

         function toggleParName(show) {
            const container = document.getElementById("parNameContainer");
            const input = document.getElementById("parName");

            container.classList.toggle("hidden", !show);
            input.required = show; // Hace obligatorio el campo si se selecciona "Yes"
        }

        function createRow() {
      const container = document.getElementById("orderContainer");
      const row = document.createElement("div");
      row.className = "grid grid-cols-12 gap-3 items-center bg-white p-4 rounded shadow text-black w-full";
      row.setAttribute("data-index", orderIndex);

      row.innerHTML = `
        <button onclick="deleteRow(this)" class="text-red-500 text-xl">Delete</button>
        <input type="number" class="col-span-1 border p-2" placeholder="Cantidad" oninput="checkLastRow(this)">
        <select class="col-span-1 border p-2">
          <option>EACH</option>
          <option>Pack</option>
          <option>Box</option>
          <option>Kg</option>
          <option>Meter</option>
          <option>Feet</option>
          <option>Oz</option>
          <option>Lt</option>
          <option>Kg</option>
        </select>
        <select class="col-span-1 border p-2">
          <option selected>USD</option>
          <option>MXN</option>
        </select>
        <input type="text" class="col-span-1 border p-2" placeholder="Part Num">
        <input type="text" class="col-span-1 border p-2" placeholder="Brand">
        <input type="text" class="col-span-1 border p-2" placeholder="Model">
        <input type="text" class="col-span-2 border p-2" placeholder="Description">
        <input type="number" class="col-span-1 border p-2" placeholder="Unit Price" onblur="formatCurrency(this)">
        <input type="text" class="col-span-1 border p-2 bg-gray-100" placeholder="Total Price" readonly>
        <input type="text" class="col-span-8 w-full border p-2" placeholder="Link">
      `;

      container.appendChild(row);
      orderIndex++;
    }

        
          function checkLastRow(input) {
              const rows = document.querySelectorAll("#orderContainer > div");
              const lastRow = rows[rows.length - 1];

              // Si el input está en la última fila
              if (input.parentElement === lastRow) {
                  createRow();
              }
        // Buscar el campo de Unit Price dentro de la misma fila
            const precioUnitario = input.parentElement.querySelector("input[placeholder='Unit Price']");

            // Si existe y tiene valor, aplicar formato
            if (precioUnitario && precioUnitario.value.trim() !== "") {
                formatCurrency(precioUnitario);
            }

          }


        function deleteRow(button) {
            const row = button.parentElement;
            row.remove();
        }

       function formatCurrency(input) {
        const value = parseFloat(input.value.replace(/,/g, '')); // Elimina comas antes de parsear
        if (!isNaN(value)) {
            // Si el input es tipo number, no se formatea con comas
            if (input.type === "number") {
                input.value = value.toFixed(2);
            } else {
                input.value = value.toLocaleString('es-MX', {
                    minimumFractionDigits: 2,
                    maximumFractionDigits: 2
                });
            }

            const row = input.parentElement;
            const cantidadInput = row.querySelector("input[type='number']");
            const cantidad = parseFloat(cantidadInput.value.replace(/,/g, ''));

            const total = row.querySelector("input[readonly]");
            if (!isNaN(cantidad)) {
                const totalValue = cantidad * value;
                total.value = totalValue.toLocaleString('es-MX', {
                    style: 'currency',
                    currency: 'MXN'
                });
            }
        }
    }



        function resetForm() {
            document.getElementById("orderContainer").innerHTML = "";
            orderIndex = 0;
            createRow();
        }
    function checkOrder() {
    const rows = document.querySelectorAll("#orderContainer > div");
    let isValid = true;
    let hasData = false;

    rows.forEach((row, index) => {
        const cantidad = row.querySelector("input[placeholder='Cantidad']");
        const descripcion = row.querySelector("input[placeholder='Description']");
        const precioUnitario = row.querySelector("input[placeholder='Unit Price']");
        const link = row.querySelector("input[placeholder='Link']");       

        const cantidadVal = cantidad?.value.trim();
        const descripcionVal = descripcion?.value.trim();
        const precioVal = precioUnitario?.value.trim();
        const linkVal = link?.value.trim();

        const isEmptyRow = !cantidadVal && !descripcionVal && !precioVal && !linkVal;

        if (index === rows.length - 1 && isEmptyRow) {
            // Último renglón vacío, lo ignoramos
            return;
        }

        if (cantidadVal || descripcionVal || precioVal || linkVal) {
            hasData = true;
        }

        let rowValid = true;

        if (!cantidadVal) {
            cantidad.classList.add("border-red-500");
            rowValid = false;
        } else {
            cantidad.classList.remove("border-red-500");
        }

        if (!descripcionVal) {
            descripcion.classList.add("border-red-500");
            rowValid = false;
        } else {
            descripcion.classList.remove("border-red-500");
        }

        if (!precioVal) {
            precioUnitario.classList.add("border-red-500");
            rowValid = false;
        } else {
            precioUnitario.classList.remove("border-red-500");
        }

        if (!linkVal || (!linkVal.includes("http://") && !linkVal.includes("https://"))) {
            link.classList.add("border-red-500");
            rowValid = false;
        } else {
            link.classList.remove("border-red-500");
        }

        
        const rfqDescription = document.getElementById("rfqDescription");
        if (rfqDescription && rfqDescription.value.trim() === "") {
            rfqDescription.classList.remove("border-gray-600");
            rfqDescription.classList.add("border-red-500");
            rowValid = false;
        } else if (rfqDescription) {
            rfqDescription.classList.remove("border-red-500");
            rfqDescription.classList.add("border-gray-600");
        }
        
        const parYesRadio = document.querySelector('input[name="parExists"][value="yes"]');
        const PAR = document.getElementById("parName");
        if (parYesRadio.checked && PAR.value.trim().length < 6) {
            PAR.classList.remove("border-gray-600");
            PAR.classList.add("border-red-500");
            PAR.value = '';
            rowValid = false;
        } else if (!parYesRadio.checked){
            PAR.value = '';
        } else {
            PAR.classList.remove("border-red-500");
            PAR.classList.add("border-gray-600");
        }

        
        const buyerEmailSelect = document.getElementById("buyerEmail");
        const selectedEmail = buyerEmailSelect.value;

        if (selectedEmail === "") {
            buyerEmailSelect.classList.remove("border-gray-300");
            buyerEmailSelect.classList.add("border-red-500");
        } else {
           buyerEmailSelect.classList.remove("border-red-500");
            buyerEmailSelect.classList.add("border-gray-300");
        }



        if (!rowValid) {
            isValid = false;
        }
    });

    const checkBtn = document.getElementById("checkButton");
    const submitBtn = document.getElementById("submitButton");

    if (!hasData) {
        checkBtn.disabled = true;
        submitBtn.disabled = true;
        return;
    }

    if (isValid) {
        submitBtn.disabled = false;
        submitBtn.classList.remove("bg-gray-400");
        submitBtn.classList.add("bg-blue-600");
        checkBtn.disabled = true;
        checkBtn.classList.remove("bg-yellow-500", "hover:bg-yellow-700");
        checkBtn.classList.add("bg-gray-400");
    } else {
        submitBtn.disabled = true;
        submitBtn.classList.remove("bg-blue-600");
        submitBtn.classList.add("bg-gray-400");
        checkBtn.classList.remove("bg-gray-400");
        checkBtn.classList.add("bg-yellow-500", "hover:bg-yellow-700");
    }
}


function confirmSubmission() {
    const confirmed = confirm("Are you sure you want to submit this requisition?");
    if (confirmed) {
        submitForm();
    }
    // Si el usuario selecciona "Cancel", no se hace nada
}


    function submitForm() {
          showModal("Request in Progress Please Wait...");
    const rows = document.querySelectorAll("#orderContainer > div");
    const rfqDescription = document.getElementById("rfqDescription");
    const vendor = document.getElementById("vendor");
    const PAR = document.getElementById("parName");
    const buyerEmailSelect = document.getElementById("buyerEmail");
    const selectedEmail = buyerEmailSelect.value;
    const data = {
        fecha: new Date().toISOString(),
        orden: [],
        rfqDescription: rfqDescription.value.trim(),
        vendor: vendor.value.trim(),
        PAR: PAR.value.trim(),
        Buyer: selectedEmail
    };

    rows.forEach((row, index) => {
        const cantidad = row.querySelector("input[placeholder='Cantidad']")?.value.trim();
        const descripcion = row.querySelector("input[placeholder='Description']")?.value.trim();
        const precioUnitario = row.querySelector("input[placeholder='Unit Price']")?.value.trim();
        const link = row.querySelector("input[placeholder='Link']")?.value.trim();
        

        const isEmptyRow = !cantidad && !descripcion && !precioUnitario && !link;

        if (index === rows.length - 1 && isEmptyRow) {
            return; // Ignorar último renglón vacío
        }

        const dataRow = {
            id: index + 1,
            cantidad: cantidad || "",
            unidad: row.querySelector("select:nth-of-type(1)")?.value || "",
            moneda: row.querySelector("select:nth-of-type(2)")?.value || "",
            parte: row.querySelector("input[placeholder='Part Num']")?.value || "",
            Brand: row.querySelector("input[placeholder='Brand']")?.value || "",
            Model: row.querySelector("input[placeholder='Model']")?.value || "",
            descripcion: descripcion || "",
            precioUnitario: precioUnitario || "",
            precioTotal: row.querySelector("input[placeholder='Total Price']")?.value || "",
            link: link || ""
        };

        data.orden.push(dataRow);
    });
      axios.post("/DP/AJAX/CreateRFQ.aspx", data)
          .then(response => {
            closeModal();
              if (response.data.status === "OK") {
                  showModal("Proceso exitoso: " + response.data.message);
              } else {
                  showModal("Error en el proceso: " + response.data.message);
              }
          })
          .catch(error => {
            closeModal();
              showModal("Error al guardar: " + error.message);
          });

}

function showModal(message) {
      document.getElementById("modalMessage").innerText = message;
      document.getElementById("modal").classList.remove("hidden");
    }

    function closeModal() {
      document.getElementById("modal").classList.add("hidden");
    }


        // Detectar cambios en campos para revalidar
        
          document.addEventListener("input", () => {              
            const submitBtn = document.getElementById("submitButton");
                const checkBtn = document.getElementById("checkButton");

                // Desactivar Submit y cambiar color a gris
                submitBtn.disabled = true;
                submitBtn.classList.remove("bg-blue-600");
                submitBtn.classList.add("bg-gray-400");

                // Activar Check Order y cambiar color a amarillo
                checkBtn.disabled = false;
                checkBtn.classList.remove("bg-gray-400");
                checkBtn.classList.add("bg-yellow-500", "hover:bg-yellow-700");

          });


        window.onload = () => {
              createRow();
              document.getElementById("submitButton").disabled = true;
              document.getElementById("checkButton").disabled = true;
            };

    </script>
</body>
</html>