<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Resumen.aspx.cs" Inherits="Resumen" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="x-ua-compatible" content="ie=edge" />
    <title> Resumen </title>
		
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

    <link rel="stylesheet" href="css/bootstrap-select.css" />
    <script src="js/bootstrap-select.min.js"></script>

	<style>
        body {
            font-family: 'Arial';
        }
        th {
            text-align: center;
            font-size: 12px;
        }
        td {
            font-size: 12px;
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
        .list-group-item {
            background-color: transparent;
        }
        g[class$='creditgroup'] {
	        display: none !important;
	    }
        .card.card-gray > .card-header {
            background-color: #d9d9d9;
        }

        .dropTableButton
        {
            width: 100%;
            padding: 5px;
            margin-top: 10px;
            cursor: pointer;
            background-color: #01AC9E;
            color: #FFFFFF;
            border: 0px;
        }

        .dropTableButton:hover
        {
            background-color: #016B63;
        }

        .dropTableDiv
        {
            padding: 5px;
            background-color: #E0E3E6;
        }

        #xlbttn
        {
            border: none;
            color: white;
            padding: 10px;
            text-align: center;
            text-decoration: none;
            display: inline-block;
            font-size: 16px;
            margin: 10px;
            cursor: pointer;
            background-color: #B6D0CF;
        }

        #xlbttn:hover
        {
            background-color: #929D96;
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
                                <li>
                                    <a href="Checklist.aspx?us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>&p=<%=lblPlanta.Text %>">
                                        <i class="fa fa-list-ol"></i> Checklist 
                                    </a>
                                </li>
                                <li>
                                    <a href="Areas.aspx">
                                        <i class="fa fa-th-large"></i> Areas 
                                    </a>
                                </li>
                                <li>
                                    <a href="Historial.aspx?us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>&p=<%=lblPlanta.Text %>">
                                        <i class="fa fa-clock-o"></i> Historial
                                    </a>
                                </li>
                                <li class="active">
                                    <a href="#.aspx">
                                        <i class="fa fa-area-chart"></i> Reportes 
                                        <i class="fa arrow"></i>
                                    </a>
                                    <ul class="sidebar-nav">
                                        <li class="active">
                                            <a href="Resumen.aspx?p=<%=lblPlanta.Text %>&us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>"> <i class="fa fa-line-chart"></i> &nbsp; Resumen </a>
                                        </li>
                                        <li>
                                            <a href="Performance.aspx?p=<%=lblPlanta.Text %>&us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>"> <i class="fa fa-bar-chart"></i> &nbsp; Performance </a>
                                        </li>                                        
                                        <li>
                                            <a href="Reportes.aspx?p=<%=lblPlanta.Text %>&us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>"> <i class="fa fa-th"></i> &nbsp; Scorecard </a>
                                        </li>
                                        <!--<li>
                                            <a href="MFG101.aspx?p=<%=lblPlanta.Text %>&us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>"> <i class="fa fa-th"></i> &nbsp; MFG 101 </a>
                                        </li>-->
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
                        <h2 class="title"> Resumen </h2>
                    </div>
                    <section class="section">
                        <div class="row">
                            <div class="col-sm-auto">
                                <label class="control-label" for="ddlYear">A&ntilde;o</label>
                                <asp:DropDownList ID="ddlYear" CssClass="form-control" runat="server"></asp:DropDownList>
                            </div>
                            <div class="col-sm-auto">
                                <label class="control-label" for="ddlMes">Mes</label>
                                <asp:DropDownList ID="ddlMes" CssClass="form-control" runat="server"></asp:DropDownList>
                            </div>
                            <div class="col-sm-auto">
                                <asp:Button ID="btnMostrar" CssClass="btn btn-primary" runat="server" Text="Mostrar" OnClick="btnMostrar_Click"/>
                            </div>
                        </div>
                        <div class="row">
							<div class="col-sm-5">
                                <div id="chartPlantas" runat="server" visible="true"></div>
                            </div>
                            
                            <div class="col-sm-4">
                                <div id="chartPerformance" runat="server" visible="true"></div>
                            </div>
                            <div class="col-sm-3 text-center">
                                <div class="row">
                                    <div class="col-sm-2"></div>
                                    <div class="col-sm-8">
                                        <p>Performance por Regi&oacute;n <%=ddlMes.SelectedItem.Text %> <%=ddlYear.SelectedItem.Text %></p>
                                        <br />
                                        <asp:Literal ID="litTablaRegion" runat="server"></asp:Literal>
                                    </div>
                                    <div class="col-sm-2"></div>
                                </div>                                
                            </div>
                        </div>
                        <br />
                        <div class="row">
                            <div class="col-sm-6">
                                <div id="chartResultadoMensual" runat="server" visible="true"></div>
                            </div>
                            <div class="col-sm-6">                                    
                                <asp:Literal ID="litItems" runat="server"></asp:Literal>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-sm-6" id="colPlanes"  runat="server" visible="false">
                                <br />
                                <div id="Planes" runat="server" visible="false"></div>
                                <br />
                            </div>
                        </div>
                    </section>
                </article>
				
				<label><%=print%></label>
				
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
                <asp:Literal ID="litMensaje" runat="server"></asp:Literal>
            </div>
        </div>
        <div class="modal fade" id="myModal" role="dialog" style="margin-top: 60px">
		    <div class="modal-dialog">
			    <!-- Modal content-->
			    <div class="modal-content" >
                    <div class="modal-header">
                        <h3 id="modalTitle">Performance planta</h3>
				        <button type="button" class="close" style="color: white" data-dismiss="modal">&times;</button>
				    </div>
                    <div class="modal-body">
                        <div class="row">
                            <div class="col-sm-12">
                                <div id="divGraphModal" runat="server"></div>
                            </div>
                        </div>
                    </div>
			    </div>
			</div>
	    </div>
    </form>
</body>
<script type="text/javascript" src="js/fusioncharts.js"></script>
<script type="text/javascript" src="js/fusioncharts.theme.fusion.js"></script>
<script type="text/javascript" src="js/fusioncharts.charts.js"></script>
<script>
    var dataResultadoMensual = {
        chart: {
            caption: "Performance por mes (<%=ddlYear.SelectedItem.Text%>)",
            theme: "fusion",
            showValues: "1",
            yAxisName: "Total",
            XAxisName: "Mes",
            drawcrossline: "1",
            decimalSeparator: ".",
            thousandSeparator: ",",
            decimals: "1",
            numbersuffix: "%",
            yaxismaxvalue: "100",
            formatNumberScale: "0",
            bgColor: "#f0f3f6",
            labelDisplay: "rotate",
            slantLabel: "1"
        },
        categories: [{
            category: [<%=categoria%>]
        }],
        dataset: [
            {
                seriesName: "Full Year",
                showValues: "1",
                plottooltext: "$label: $value%",
                data: [<%=serieFY%>]
            },
            {
                seriesName: "Mensual",
                showValues: "1",
                plottooltext: "$label: $value%",
                renderAs: "line",
                color: "#d9d9d9",
                data: [<%=serieMensual%>]
            }
        ],
        trendlines: [{
            line: [{
                "color": "#28a745",
                "startvalue": "98",
                "tooltext": "Target: 98%",
                "valueOnRight": "1"
                }]
        }]
    };

    var dataPerformance = {
        chart: {
            caption: "Total Performance <%=ddlMes.SelectedItem.Text %> <%=ddlYear.SelectedItem.Text %>",
            origw: "320",
            origh: "300",
            gaugeouterradius: "130",
            gaugestartangle: "205",
            gaugeendangle: "-25",
            showvalue: "1",
            valuefontsize: "30",
            majortmnumber: "13",
            majortmthickness: "2",
            majortmheight: "13",
            minortmheight: "7",
            minortmthickness: "1",
            minortmnumber: "1",
            showgaugeborder: "0",
            theme: "fusion",
            numbersuffix: "%",
            bgColor: "#f0f3f6"
        },
        colorrange: {
            color: [
                {
                minvalue: "0",
                maxvalue: "94.9",
                code: "#dc3545"
                },
                {
                    minvalue: "95",
                    maxvalue: "97.9",
                    code: "#ffc107"
                },
                {
                minvalue: "98",
                maxvalue: "100",
                code: "#28a745"
                }
            ]
        },
        dials: {
            dial: [
                {
                    value: "<%=performance%>",
                    bgcolor: "#000000",
                    basewidth: "8"
                }
            ]
        }
    };

    var dataPlantas = {
        chart: {
            caption: "Performance por planta <%=ddlMes.SelectedItem.Text %> <%=ddlYear.SelectedItem.Text %>",
            plottooltext: "<b>$label</b>: <b>$value%</b>",
            theme: "fusion",
            showValues: "1",
            rotateValues: "0",
            decimalSeparator: ".",
            thousandSeparator: ",",
            decimals: "1",
            formatNumberScale: "0",
            bgColor: "#f0f3f6",
            showLegend: "1",
            numbersuffix: "%",
            slantLabel: "1",
            labelDisplay: "rotate",
            placeValuesInside: "0"
        },
        data: [ <%=performance_plantas%>]
    };

    FusionCharts.ready(function () {

        var chartResultadoMensual = new FusionCharts({
            type: "mscombi2d",
            renderAt: "chartResultadoMensual",
            width: "100%",
            height: "350",
            dataFormat: "json",
            dataSource: dataResultadoMensual
        }).render();

        var chartPerformance = new FusionCharts({
            type: "angulargauge",
            renderAt: "chartPerformance",
            width: "100%",
            height: "350",
            dataFormat: "json",
            dataSource: dataPerformance
        }).render();

        var chartPlantas = new FusionCharts({
            type: "column2d",
            renderAt: "chartPlantas",
            width: "100%",
            height: "350",
            dataFormat: "json",
            dataSource: dataPlantas,
            events: {
                "dataPlotClick": function (eventObj, dataObj) {
                    MostrarPreguntas(dataObj['categoryLabel']);
                }
            }
        }).render();
    });

    var contenido = [<%=dataResultadoMensualPlantas%>];

    function MostrarPreguntas(valor) {
        var filtro = contenido.filter(function (item) { return item.planta == valor});
        var jsonFinal = '', parsedJson = '', resMens, graphModal;
        
        var divGraph = document.getElementById('divGraphModal');
        var title = document.getElementById('modalTitle');

        title.innerHTML = "Performance planta " + valor;

        while (divGraph.firstChild) {
            divGraph.removeChild(divGraph.firstChild);
        }

        if (filtro) {

            jsonFinal += '[';

            filtro.forEach(function (element, i) {
                jsonFinal += '{ "label":"' + element['mes'] + '", "value":"' + element['resultado'] + '", "color":"' + element['color'] + '"},';
            });

            jsonFinal = jsonFinal.substring(0, jsonFinal.length - 1);

            jsonFinal += ']';
        }

        parsedJson = JSON.parse(jsonFinal);

        graphModal = {
            chart: {
                caption: "Performance por mes (" + <%=ddlYear.SelectedItem.Text%> + ") " + valor + " ",
                plottooltext: "<b> $label </b>",
                theme: "fusion",
                showValues: "1",
                yAxisName: "Total",
                XAxisName: "Mes",
                drawcrossline: "1",
                rotateValues: "1",
                decimalSeparator: ".",
                thousandSeparator: ",",
                decimals: "1",
                numbersuffix: "%",
                yaxismaxvalue: "100",
                formatNumberScale: "0",
                bgColor: "#f0f3f6",
                labelDisplay: "rotate",
                slantLabel: "1",
                placeValuesInside: "1"
            },
            data: parsedJson,
		    trendlines: [{
                line: [{
                    "color": "#28a745",
                    "startvalue": "98",
                    "tooltext": "Target: 98%",
                    "valueOnRight": "1"
                    }]
            }]
        };
        
        resMens = new FusionCharts({
            type: "column2d",
            renderAt: "divGraphModal",
            width: "100%",
            height: "350",
            dataFormat: "json",
            dataSource: graphModal
        }).render();

        $("#myModal").modal();
    }

    function showhideTable(tbl)
    {
        var tblID = document.getElementById('tbl' + tbl);
        var bttnID = document.getElementById("drpdwnTbl_Bttn" + tbl);
        var i = 0;

        if (tblID.style.display === "none") 
        {
            tblID.style.display = "block";
            bttnID.value = bttnID.value.substring(0, bttnID.value.length - 1) + '\u25B2';
        }
        else 
        {
            tblID.style.display = "none";
            bttnID.value = bttnID.value.substring(0, bttnID.value.length - 1) + '\u25BC';
        }

        for(i = 1; i < 5; i++)
        {
            if (i !== tbl)
            {
                tblID = document.getElementById('tbl' + i);
                bttnID = document.getElementById("drpdwnTbl_Bttn" + i);
                tblID.style.display = "none";
                bttnID.value = bttnID.value.substring(0, bttnID.value.length - 1) + '\u25BC';
            }
        }
    }

    function exportSummary()
    {
        var tab_text = "<table border='2px'>";
        var j = 0;
        var k = 0;
        const tbls_array = ["nullTable", "finalAssmblyTable", "cutTable", "leadTable"];
        
        tab_text = tab_text + "<tr><td>Disciplina</td><td>Desempeño</td></tr>";
        
        for(k = 0; k < 4; k++)
        {
            tab = document.getElementById(tbls_array[k]); // id of table

            for(j = 1; j < tab.rows.length; j++) 
            {     
                tab_text = tab_text + "<tr><td>" + tab.rows[j].cells[0].innerHTML + "</td><td>" + tab.rows[j].cells[1].innerHTML + "</td></tr>";
            }
        }

        tab_text = tab_text + "</table>";

        var ua = window.navigator.userAgent;
        var msie = ua.indexOf("MSIE "); 

        if (msie > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./))      // If Internet Explorer
        {
            txtArea1.document.open("txt/html","replace");
            txtArea1.document.write(tab_text);
            txtArea1.document.close();
            txtArea1.focus(); 
            sa = txtArea1.document.execCommand("SaveAs",true,"Say Thanks to Sumit.xls");
        }  
        else                 //other browser not tested on IE 11
            sa = window.open('data:application/vnd.ms-excel,' + encodeURIComponent(tab_text));  

        return (sa);
    }
    
</script>
</html>
