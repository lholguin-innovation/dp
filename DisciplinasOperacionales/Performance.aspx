<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Performance.aspx.cs" Inherits="Performance" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="x-ua-compatible" content="ie=edge" />
    <title> Performance </title>
		
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
            font-size: 13px;
        }
        td {
            font-size: 13px;
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
                                    <a href="Areas.aspx?us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>&p=<%=lblPlanta.Text %>">
                                        <i class="fa fa-th-large"></i> &Aacute;reas 
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
                                        <li>
                                            <a href="Resumen.aspx?p=<%=lblPlanta.Text %>&us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>"> <i class="fa fa-line-chart"></i> &nbsp; Resumen </a>
                                        </li>
                                        <li class="active">
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
                        <h2 class="title"> Performance </h2>
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
                            <div class="col-sm-7 table-responsive">
                                <asp:Literal ID="litScorecard" runat="server"></asp:Literal>
                            </div>
                            <div class="col-sm-5">
                                <br /><br />
                                <div id="chartPerformance" runat="server" visible="false"></div>
                            </div>
                        </div>
                    </section>
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
                <asp:Literal ID="litMensaje" runat="server"></asp:Literal>
            </div>
        </div>
    </form>
</body>
<script type="text/javascript" src="js/fusioncharts.js"></script>
<script type="text/javascript" src="js/fusioncharts.theme.fusion.js"></script>
<script type="text/javascript" src="js/fusioncharts.charts.js"></script>
<script>
    $(document).ready(function () {
        var tabla = $("#tablaPerformance").DataTable({
            scrollY: '50vh',
            scrollX: true,
            searching: false,
            info: false,
            paging: false,
            ordering: false,
            lengthChange: false,
            columnDefs: [
                { targets: [0], 'width': '11%' },
                { targets: [1], 'width': '3%' },
                { targets: [2], 'width': '3%' },
                { targets: [3], 'width': '3%' },
                { targets: [4], 'width': '3%' },
                { targets: [5], 'width': '3%' },
                { targets: [6], 'width': '3%' },
                { targets: [7], 'width': '3%' },
                { targets: [8], 'width': '3%' },
                { targets: [9], 'width': '3%' },
                { targets: [10], 'width': '3%' },
                { targets: [11], 'width': '3%' },
                { targets: [12], 'width': '3%' },
                { targets: [13], 'width': '3%' },
            ],
            buttons: [ { extend: "excelHtml5" }]
        });

        tabla.buttons().container().appendTo("#tablaPerformance_wrapper .col-md-6:eq(0)");

        var dataScorecard = {
            chart: {
                caption: "Performance por planta (<%=tituloChart%>)",
                plottooltext: "<b> $label </b>: <b> $value % </b>",
                theme: "fusion",
                showValues: "1",
                yAxisName: "Total",
                XAxisName: "Planta",
                drawcrossline: "1",
                palettecolors: "0086b3",
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
            data: [ <%=datosPerformance%> ],
            trendlines: [{
            line: [{
                "color": "#28a745",
                "startvalue": "98",
                "tooltext": "Target: 98%",
                "valueOnRight": "1"
                }]
            }]
        };

        FusionCharts.ready(function () {
            var chartPerformance = new FusionCharts({
                type: "bar2d",
                renderAt: "chartPerformance",
                width: "100%",
                height: "550",
                dataFormat: "json",
                dataSource: dataScorecard
            }).render();
        });
    });
</script>
</html>
