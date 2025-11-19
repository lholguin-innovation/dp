<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Checklist.aspx.cs" Inherits="Checklist" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="x-ua-compatible" content="ie=edge" />
    <title> Checklist </title>
		
    <meta name="description" content="" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link rel="apple-touch-icon" href="apple-touch-icon.png" />

     <link rel="stylesheet" href="css/vendor.css" />
	<link rel="stylesheet" id="theme_style" href="css/app.css" />
	<link rel="stylesheet" type="text/css" href="css/dataTables.bootstrap4.min.css" />

	<script src="js/jquery-3.3.1.js"></script>
	<script src="js/vendor.js"></script>
	<script src="js/jquery.dataTables.min.js"></script>
	<script src="js/dataTables.bootstrap4.min.js"></script>
	<script src="js/dataTables.buttons.min.js"></script>
	<script src="js/buttons.bootstrap4.min.js"></script>
	<script src="js/jszip.min.js"></script>
	<script src="js/pdfmake.min.js"></script>
	<script src="js/vfs_fonts.js"></script>
	<script src="js/buttons.html5.min.js"></script>
	<script src="js/buttons.print.min.js"></script>
	<script src="js/buttons.colVis.min.js"></script>
    <script src="js/app.js"></script>

    <script src="js/sweetalert.js"></script>
    <link href='css/sweetalert.css' rel='stylesheet' />
    <script src='js/sweetalert.min.js'></script>

	<style>
        body {
            font-family: 'Arial';
        }
		.title {
			font-weight: 100;
			font-size: 28px;
		}
        .header, .footer, .sidebar {
            position: fixed;
        }
        .tr-tipoOSA {
            background-color: #4d4d4d;
            color: white;
            font-weight: bold;
        }
        .tr-elemento {
            background-color: #cccccc;
            color: black;
            font-weight: bold;
        }
        .nav {
            margin-left: -16px;
            margin-bottom: -17px;
            color: white;
        }
        .nav-item a, .nav-item .nav-link:hover {
            text-decoration: none;
            color: white;
        }
        a.nav-link {
            color: white;
        }
        .nav-link.active.show.nav-link-danger, .nav-link.active.show.nav-link-danger.active {
            background-color: red;
            border-color: red;
            color: white;
        }
        .nav-link.active.show.nav-link-warning {
            background-color: orange;
            border-color: orange;
            color: white;
        }
        .nav-link.active.show.nav-link-warningy {
            background-color: yellow;
            border-color: yellow;
            color: black;
        }
        .nav-link.active.show.nav-link-success {
            background-color: green;
            border-color: green;
            color: white;
        }
        .btn, .control-label, .form-control {
            font-weight: 100;
        }
        #divResultados {
            font-size: 12px;
        }
        .sinborde {
            border-bottom: none; 
            border-top: none;
        }
        tr>.sinborde{
            border-bottom: none;
            border-top: none;
        }
	</style>
</head>
<body>
    <form id="form1" runat="server" method="post">
        <div class="main-wrapper">
            <div class="app" id="app">

                <!--****** ENCABEZADO ******-->
                <header class="header">
                    <div class="header-block header-block-collapse d-lg-none d-xl-none">
                        <button class="collapse-btn" id="sidebar-collapse-btn">
                            <i class="fa fa-bars"></i>
                        </button>
                    </div>
			        <div class="header-block header-block-nav" style="color: white;">
                        <div class="name"> Disciplinas Operacionales </div>
                    </div>
                    <div class="header-block header-block-nav">
                        <ul class="nav-profile">
                            <li class="profile dropdown">
                                <a class="nav-link dropdown-toggle" data-toggle="dropdown" href="#" role="button" aria-haspopup="true" aria-expanded="false">
                                    <span class="name" style="font-weight: 100;">
								        <span class="fa fa-user icon fa-lg"></span> &nbsp; <asp:Label ID="lblNombre" runat="server" Text=""></asp:Label>
							        </span>
                                </a>
                                <div class="dropdown-menu profile-dropdown-menu" aria-labelledby="dropdownMenu1">
                                    <a class="dropdown-item" href="Logout.aspx">
                                        <i class="fa fa-power-off icon"></i> Cerrar Sesi&oacute;n 
							        </a>
                                    <a class="dropdown-item" href="Menu.aspx?us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>">
                                        <i class="fa fa-globe"></i> Plantas 
							        </a>
                                </div>
                            </li>
                        </ul>
                    </div>
                </header>

                <!--****** MENU BARRA IZQUIERDA ******-->
                <aside class="sidebar">
                    <div class="sidebar-container">

                        <!--****** LOGO APTIV ******-->
                        <div class="sidebar-header">
                            <div class="brand">
						        <img src="img/aptiv-inv.png" width="145" height="20" />
						    </div>
                        </div>

                        <!--****** NAVEGACION ******-->
                        <nav class="menu">
                            <br />
                            <div class="text-center">
                                <asp:Label ID="lblPlanta" Font-Size="Large" runat="server" ForeColor="White" Text=""></asp:Label>
                            </div>
                            <br />
                            <ul class="sidebar-menu metismenu" id="sidebar-menu">
                                <li class="active">
                                    <a href="Checklist.aspx?us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>&p=<%=lblPlanta.Text %>">
                                        <i class="fa fa-list-ol"></i> Checklist 
                                    </a>
                                </li>
                                <li>
                                    <a href="Areas.aspx?us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>&p=<%=lblPlanta.Text %>">
                                        <i class="fa fa-th-large"></i> &Aacute;reas 
                                    </a>
                                </li>
                                <li>
                                    <a href="Historial.aspx?us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>&p=<%=lblPlanta.Text %>">
                                        <i class="fa fa-clock-o"></i> Historial
                                    </a>
                                </li>
                                <li>
                                    <a href="#.aspx">
                                        <i class="fa fa-area-chart"></i> Reportes 
                                        <i class="fa arrow"></i>
                                    </a>
                                    <ul class="sidebar-nav">
                                        <li>
                                            <a href="Resumen.aspx?p=<%=lblPlanta.Text %>&us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>"> <i class="fa fa-line-chart"></i> &nbsp; Resumen </a>
                                        </li>
                                        <li>
                                            <a href="Performance.aspx?p=<%=lblPlanta.Text %>&us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>"> <i class="fa fa-bar-chart"></i> &nbsp; Performance </a>
                                        </li>                                        
                                        <li>
                                            <a href="Reportes.aspx?p=<%=lblPlanta.Text %>&us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>"> <i class="fa fa-th"></i> &nbsp; Scorecard </a>
                                        </li>
                                    </ul>
                                </li>
                                <li>
                                    <a href="Responsables.aspx?us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>&p=<%=lblPlanta.Text %>">
                                        <i class="fa fa-user"></i> Responsables 
                                    </a>
                                </li>
                                <li>
                                    <a href="ContenidoDinamico.aspx?us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>&p=<%=lblPlanta.Text %>">
                                        <i class="fa fa-picture-o"></i> Contenido Din&aacute;mico 
                                    </a>
                                </li>
                                <li>
                                    <a href="Calendario.aspx?us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>&p=<%=lblPlanta.Text %>">
                                        <i class="fa fa-calendar"></i> Agenda 
                                    </a>
                                </li>
                            </ul>
                        </nav>
                    </div>
                </aside>

                <!--****** MENU DESPLEGABLE (MOVIL) ******-->
                <div class="sidebar-overlay" id="sidebar-overlay"></div>
                <div class="sidebar-mobile-menu-handle" id="sidebar-mobile-menu-handle"></div>
                <div class="mobile-menu-handle"></div>

                <!--****** CONTENIDO ******-->
                <article class="content dashboard-page">
                    <div class="title-block">
                        <h2 class="title"> Checklist </h2>
                    </div>
                    <section class="section">
                        <div class="row">
                            <div class="col-sm-3">
                                <label class="control-label" for="ddlArea">&Aacute;rea</label>
                                <asp:DropDownList ID="ddlArea" CssClass="form-control" runat="server"></asp:DropDownList>
                            </div>
                            <div class="col-sm-9">
                                <asp:Button ID="btnRealizar" CssClass="btn btn-primary" runat="server" Text="Realizar" OnClick="btnRealizar_Click" />
                            </div>          
                        </div>
                        <br />      
                        <asp:Literal ID="litChecklist" runat="server" Text=""></asp:Literal>
                        <asp:Literal ID="litDebug" runat="server" Text=""></asp:Literal>
                        <div class="row">
                            <div class="col-sm-12 text-center">
                                <input type="button" id="btnValidar" class="btn btn-primary" value="Verificar" runat="server" visible="false" onclick="Validar();" />
                            </div>
                        </div>
                    </section>
                    <br />
                    <div id="divResultados" style="visibility: hidden;">
                        <div class="title-block" style="margin-bottom: 10px;">
                            <h2 class="title">Resultados</h2>
                        </div>
                        <section>
                            <div class="row" id="Resultados" >

                            </div>
                        </section>
                    </div>
                    <br />
                    <div id="divPlanes" style="visibility: hidden;">
                        <div class="title-block" style="margin-bottom: 10px;">
                            <h2 class="title"> Planes de acci&oacute;n </h2>
                        </div>
                        <section class="section" >
                            <div class="row">
                                <div class="col-sm-12 table-responsive">
                                    <table class="table" id="tablaPlanes" width="100%">
                                        <thead>
                                            <tr class="tr-tipoOSA text-center" style='font-size: 12px;'>
                                                <th>Codigo</th>
                                                <th>Disciplina</th>
                                                <th>Plan de acci&oacute;n</th>
                                                <th>Responsable</th>
                                                <th>Fecha promesa</th>
                                            </tr>
                                        </thead>
                                        <tbody id="tbodyPlanes" style='font-size: 12px;'>

                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </section>
                    </div>
                    <div class="row" id="divEnviar" style="visibility: hidden">
                        <div class="col-sm-12 text-center">
                            <asp:Button CssClass="btn btn-success" Visible="true" ID="btnEnviar" runat="server" Text="Enviar" OnClick="btnEnviar_Click" />
                        </div>
                    </div>
                <asp:Literal ID="litMensaje" runat="server"></asp:Literal>
                </article>

                <!--****** PIE DE PAGINA ******-->
                <footer class="footer">
                    <div class="footer-block author">
                        <ul>
						    <li style="font-weight: 300;"> &copy; APTIV &nbsp; </li>
                            <li style="font-weight: 300;"> &nbsp; Dise&ntilde;o: EDS NA IT Lean &nbsp; </li>
                            <li style="font-weight: 300;"> &nbsp; Usuario: <asp:Label ID="lblUsuario" runat="server" Text=""></asp:Label></li>
                        </ul>
                    </div>
                </footer>
            </div>
        </div>

        <!--************** MODAL **************-->
	    <div class="modal fade" id="myModal" role="dialog" style="margin-top: 60px">
		    <div class="modal-dialog">
			    <!-- Modal content-->
			    <div class="modal-content" >
                    <div class="modal-header">
				        <button type="button" class="close" style="color: white" data-dismiss="modal">&times;</button>
				    </div>
                    <div class="modal-body">
                        <div class="row">
                            <div class="col-sm-12">
                                <div  class="modal-body" id="modal_body">
				                    <div class="tab-content">
                                        <div role="tabpanel" class="tab-pane fade in active show" id="contenido"></div>
                                    </div>
				                </div>
                            </div>
                        </div>
                    </div>
			    </div>
			</div>
	    </div>
        <!--***********************************-->
    </form>
</body>
<script>
    $(document).ready(function () {
        var table = $('#tablaDisciplinas').DataTable({
            searching: false,
            scrollY: "40vh",
            scrollX: true,
            info: false,
            paging: false,
            ordering: false,
            lengthChange: false
        });

        table.buttons().container()
            .appendTo('#tablaDisciplinas_wrapper .col-md-6:eq(0)');

        var table2 = $('#tablaAsistencia').DataTable({
            searching: false,
            scrollY: "40vh",
            scrollX: true,
            info: false,
            paging: false,
            ordering: false,
            lengthChange: false
        });

        table2.buttons().container()
            .appendTo('#tablaAsistencia_wrapper .col-md-6:eq(0)');
    });
</script>
<script>
    var total_disciplinas = <%=total_disciplinas%>, nok = 0, a = 0, avgS, avgP, avgQ, avgV, avgC, totalEvaluacion = 0;
    var inicio_id_disciplinas = <%=inicio_id_disciplinas%>;
    var codigo_disciplina;
    var codigos_disciplinas;
    var no_contestada = '';

    function MostrarContenido(ruta, extension) {
        var contenido = document.getElementById('contenido');
        var embed;

        if (extension == 'pdf') 
        {
            embed = document.createElement('embed');
            embed.setAttribute('src', ruta);
            embed.setAttribute('width', '100%');
            embed.setAttribute('height', '500px');
        } 
        else
        {
            embed = document.createElement('embed');
            embed.setAttribute('src', ruta);
            embed.setAttribute('width', '100%');
            embed.setAttribute('height', '100%');
        }

        while (contenido.firstChild) {
            contenido.removeChild(contenido.firstChild);
        }

        contenido.appendChild(embed);

        $("#myModal").modal();
    }

    function Validar() 
    {
        codigos_disciplinas = [];

        avgS = 0, avgP = 0, avgQ = 0, avgV = 0, avgC = 0;

        //Por cada pregunta
            console.log(total_disciplinas);
     //   for (var i = 1; i <= total_disciplinas; i++) {
        for (var i = inicio_id_disciplinas; i < (inicio_id_disciplinas+total_disciplinas); i++) 
        {
            console.log(i);
            //Si los los radios son seleccionados
            if (document.getElementById('OK' + i).checked == true || document.getElementById('NOK' + i).checked == true) {

                //Si el radio OK es seleccionado
                if (document.getElementById('OK' + i).checked == true) {

                    var elemento = document.getElementById('elemento' + i).value;
                    var valor;

                    if (elemento == 'Seguridad') { 
                        valor = document.getElementById('valor' + i).value; 
                        avgS += parseFloat(valor);
                    }
                    if (elemento == 'Gente') { 
                        valor = document.getElementById('valor' + i).value; 
                        avgP += parseFloat(valor); 
                    }
                    if (elemento == 'Calidad') { 
                        valor = document.getElementById('valor' + i).value; 
                        avgQ += parseFloat(valor); 
                    }
                    if (elemento == 'Volumen') { 
                        valor = document.getElementById('valor' + i).value; 
                        avgV += parseFloat(valor); 
                    }
                    if (elemento == 'Costo') { 
                        valor = document.getElementById('valor' + i).value; 
                        avgC += parseFloat(valor); 
                    }
                }

                //Si el radio NOK es seleccionado
                if (document.getElementById('NOK' + i).checked == true) {
                    codigos_disciplinas[a] = document.getElementById('codigo' + i).value;
                    a++;
                    nok++;
                }
            } 
            else
            {
                //Arma cadena con los codigos de disciplinas pendientes
                codigo_disciplina = document.getElementById('codigo' + i).value;
                no_contestada += codigo_disciplina + ', ';
            }
        }

        //Si todas fueron contestadas
        if (no_contestada == '') {

            //Si hay al menos un NOK, arma tabla para planes de accion
            if (nok > 0) {
                TablaEvaluacion();
                TablaPlanes(codigos_disciplinas);
                document.getElementById("divEnviar").style.marginTop = null;
            }
            else
            {
                TablaEvaluacion();
                //Si la tabla de planes esta visible, ocultarla
                if (document.getElementById("divPlanes").style.visibility == "visible") {
                    //Elimina rows en caso de tenerlos
                    while (document.getElementById("tbodyPlanes").firstChild) {
                        document.getElementById("tbodyPlanes").removeChild(document.getElementById("tbodyPlanes").firstChild);
                    }
                    document.getElementById("divPlanes").style.visibility = "hidden";
                    document.getElementById("divEnviar").style.marginTop = "-280px";
                }
                else 
                {
                    document.getElementById("divEnviar").style.marginTop = "-140px";
                }
                document.getElementById("divPlanes").style.visibility = "hidden";
            }

            document.getElementById("divResultados").style.visibility = "visible";
            document.getElementById('divResultados').scrollIntoView();
            document.getElementById("divEnviar").style.visibility = "visible";

            nok = 0;
        }
        else
        {
            no_contestada = no_contestada.substring(0, no_contestada.length - 2);
            swal('','Falta de contestar disciplinas con codigo ' + no_contestada + '.', 'warning');
            no_contestada = '';
        }
    }

    function TablaEvaluacion() {
        
        //Crea variable para crear contenido
        var resultados = document.getElementById("Resultados");

        //Elimina rows en caso de tenerlos
        while (resultados.firstChild) {
            resultados.removeChild(resultados.firstChild);
        }

        //Variables para columnado
        var br = document.createElement('br');
        var col3 = document.createElement('div');
        var col9 = document.createElement('div');
        var titulo1 = document.createElement('h5');
        var titulo2 = document.createElement('h5');
        var total = document.createElement('h1');
        var tabla = document.createElement('table');
        var thead = document.createElement('thead');
        var tbody = document.createElement('tbody');
        var tr1 = document.createElement('tr');
        var tr2 = document.createElement('tr');
        var th1 = document.createElement('th');
        var th2 = document.createElement('th');
        var th3 = document.createElement('th');
        var th4 = document.createElement('th');
        var th5 = document.createElement('th');
        var th6 = document.createElement('th');
        var th7 = document.createElement('th');
        var td1 = document.createElement('td');
        var td2 = document.createElement('td');
        var td3 = document.createElement('td');
        var td4 = document.createElement('td');
        var td5 = document.createElement('td');
        var td6 = document.createElement('td');
        var td7 = document.createElement('td');
        var w1, w2, w3, w4, w5, totalmes;

        w1 = <%=w1%>; w2 = <%=w2%>; w3 = <%=w3%>; w4 = <%=w4%>; w5 = <%=w5%>; totalmes = <%=totalmes%>;

        col3.className = 'col-sm-3 text-center';
        col9.className = 'col-sm-9 text-center';

        titulo1.innerHTML = "Total";
        totalEvaluacion = (avgS + avgP + avgQ + avgV + avgC) / 5;
        totalEvaluacion = totalEvaluacion.toFixed();
        if (totalEvaluacion >= 99.5) { totalEvaluacion = 100; }
        if (totalEvaluacion < 1) { totalEvaluacion = 0; }

        if (totalEvaluacion < 95) { total.className = 'text-danger'; }
        if (totalEvaluacion >= 95 && totalEvaluacion < 98) { total.className = 'text-warning'; }
        if (totalEvaluacion >= 98) { total.className = 'text-success'; }
        if (totalEvaluacion == 0) { total.removeAttribute('class'); }

        total.innerHTML = totalEvaluacion + "%";

        titulo2.innerHTML = "Historial del mes (<%=periodo%>)";

        th1.innerHTML = "Area";
        th2.innerHTML = "W1";
        th3.innerHTML = "W2";
        th4.innerHTML = "W3";
        th5.innerHTML = "W4";
        th6.innerHTML = "W5";
        th7.innerHTML = "Promedio Mes";

        tr1.appendChild(th1);
        tr1.appendChild(th2);
        tr1.appendChild(th3);
        tr1.appendChild(th4);
        tr1.appendChild(th5);
        tr1.appendChild(th6);
        tr1.appendChild(th7);

        tr1.className = 'tr-tipoOSA text-center';
        tr1.setAttribute("style", "font-size: 13px;");
        thead.appendChild(tr1);
        
        td1.setAttribute("style", "font-size: 15px;");
        td1.innerHTML = "<%=area%>";
        td2.innerHTML = "<%=w1 %>%";
        td3.innerHTML = "<%=w2 %>%";
        td4.innerHTML = "<%=w3 %>%";
        td5.innerHTML = "<%=w4 %>%";
        td6.innerHTML = "<%=w5 %>%";
        td7.innerHTML = "<%=totalmes %>%";

        if (w1 < 95) { td2.className = 'text-danger'; }
        if (w1 >= 95 && w1 < 98) { td2.className = 'text-warning'; }
        if (w1 >= 98) { td2.className = 'text-success'; }
        if (w1 == 0) { td2.removeAttribute('class'); }

        if (w2 < 95) { td3.className = 'text-danger'; }
        if (w2 >= 95 && w2 < 98) { td3.className = 'text-warning'; }
        if (w2 >= 98) { td3.className = 'text-success'; }
        if (w2 == 0) { td3.removeAttribute('class'); }

        if (w3 < 95) { td4.className = 'text-danger'; }
        if (w3 >= 95 && w3 < 98) { td4.className = 'text-warning'; }
        if (w3 >= 98) { td4.className = 'text-success'; }
        if (w3 == 0) { td4.removeAttribute('class'); }

        if (w4 < 95) { td5.className = 'text-danger'; }
        if (w4 >= 95 && w4 < 98) { td5.className = 'text-warning'; }
        if (w4 >= 98) { td5.className = 'text-success'; }
        if (w4 == 0) { td5.removeAttribute('class'); }

        if (w5 < 95) { td6.className = 'text-danger'; }
        if (w5 >= 95 && w5 < 98) { td6.className = 'text-warning'; }
        if (w5 >= 98) { td6.className = 'text-success'; }
        if (w5 == 0) { td6.removeAttribute('class'); }

        if (totalmes < 95) { td7.className = 'text-danger'; }
        if (totalmes >= 95 && totalmes < 98) { td7.className = 'text-warning'; }
        if (totalmes >= 98) { td7.className = 'text-success'; }
        if (totalmes == 0) { td7.removeAttribute('class'); }

        tr2.appendChild(td1);
        tr2.appendChild(td2);
        tr2.appendChild(td3);
        tr2.appendChild(td4);
        tr2.appendChild(td5);
        tr2.appendChild(td6);
        tr2.appendChild(td7);

        tr2.className = 'text-center';
        tr2.setAttribute("style", "font-size: 18px;");
        tbody.appendChild(tr2);

        tabla.className = 'table';
        tabla.appendChild(thead);
        tabla.appendChild(tbody);

        col3.appendChild(titulo1);
        col3.appendChild(br);
        col3.appendChild(total);

        col9.appendChild(titulo2);
        col9.appendChild(tabla);

        resultados.appendChild(col3);
        resultados.appendChild(col9);
    }

    function TablaPlanes(cod_disciplinas) {
        //Crea variables para crear la tabla
        var cuerpo = document.getElementById("tbodyPlanes");

        //Elimina rows en caso de tenerlos
        while (cuerpo.firstChild) {
            cuerpo.removeChild(cuerpo.firstChild);
        }

        //Por cada codigo de pregunta contestada en NOK, genera un textbox
        cod_disciplinas.forEach( function(elemento) { 
            //Crea variables para los rows
            var tr = document.createElement('tr');
            var td1 = document.createElement('td'); //Codigo
            var td2 = document.createElement('td'); //Disciplina
            var td3 = document.createElement('td'); //Plan
            var td4 = document.createElement('td'); //Responsable
            var td5 = document.createElement('td'); //Fh promesa
            var txt1 = document.createElement('input'); //Plan
            var txt2 = document.createElement('input'); //Responsable
            var txt3 = document.createElement('input'); //Fh promesa
            var disciplina = document.getElementById(elemento).textContent;

            txt1.setAttribute("type", "text");
            txt2.setAttribute("type", "text");
            txt3.setAttribute("type", "date");
            txt1.setAttribute("style", "font-size: 12px;");
            txt2.setAttribute("style", "font-size: 12px;");
            txt3.setAttribute("style", "font-size: 12px;");
            txt1.className = 'form-control';
            txt2.className = 'form-control';
            txt3.className = 'form-control';
            td2.className = 'text-justify';

            txt1.setAttribute("id", "plan" + elemento + "");
            txt1.setAttribute("name", "plan" + elemento + "");
            txt2.setAttribute("id", "responsable" + elemento + "");
            txt2.setAttribute("name", "responsable" + elemento + "");
            txt3.setAttribute("id", "fh_promesa" + elemento + "");
            txt3.setAttribute("name", "fh_promesa" + elemento + "");

            td1.innerHTML = elemento;
            td2.innerHTML = disciplina;
            td3.appendChild(txt1);
            td4.appendChild(txt2);
            td5.appendChild(txt3);

            tr.appendChild(td1);
            tr.appendChild(td2);
            tr.appendChild(td3);
            tr.appendChild(td4);
            tr.appendChild(td5);

            cuerpo.appendChild(tr);
        });

        $('#tablaPlanes').DataTable( {
            searching: false,
            scrollY: "25vh",
            scrollX: true,
            info: false,
            paging: false,
            ordering: false,
            lengthChange: false,
            destroy: true,
            retrieve:true,
        } );

        document.getElementById("divPlanes").style.visibility = "visible";
    }
</script>
</html>
