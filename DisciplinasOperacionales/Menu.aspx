<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Menu.aspx.cs" Inherits="Menu" %>

<!DOCTYPE html>

<html class="no-js" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="x-ua-compatible" content="ie=edge" />
    <title>Menu - Selecci&oacute;n de planta</title>
		
    <meta name="description" content="" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link rel="apple-touch-icon" href="apple-touch-icon.png" />

    <link rel="stylesheet" href="css/vendor.css" />
	<link rel="stylesheet" id="theme_style" href="css/app.css" />
    <link rel="stylesheet" href="css/style2.css" />
	<link rel="stylesheet" href="css/normalize.min.css"/>

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
	</style>
</head>
<body>
    <form id="form1" runat="server" method="post">
        <div class="main-wrapper">
            <div class="app" id="app" style="padding-left: 0px;">

                <!--****** ENCABEZADO ******-->
                <header class="header" style="left: 0px;">
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
                                </div>
                            </li>
                        </ul>
                    </div>
                </header>
                
                <!--****** MENU DESPLEGABLE (MOVIL) ******-->
                <div class="sidebar-overlay" id="sidebar-overlay"></div>
                <div class="sidebar-mobile-menu-handle" id="sidebar-mobile-menu-handle"></div>
                <div class="mobile-menu-handle"></div>

                <!--****** CONTENIDO ******-->
                <div class="container">
		<svg class="menu" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 792 792">
			<defs>
				<path class="path-1" d="M45 67.9c0 2.3 1.9 4.1 4.2 4.1a4.1 4.1 0 1 0 0-8.3 4.1 4.1 0 0 0-4.1 4.2zm6 0c0 1-.8 1.7-1.8 1.7s-1.8-.7-1.8-1.7.8-1.8 1.8-1.8 1.8.7 1.8 1.8z"/>
			</defs>
			<g class="All-on" fill="none" fill-rule="evenodd" transform="translate(-571 -143)">
				<g class="menu" transform="translate(571 143)">
					<g class="outside-layer">
						<circle class="outer-cirlce-background" cx="396" cy="396" r="396" fill="#000" fill-opacity=".4"/>
						<g class="more-menu" transform="translate(654 229)">
							<g class="new-button" transform="translate(28 90)">
								<title>Frontera</title>
                                <a xlink:href="Resumen.aspx?us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>&p=Frontera">
								<circle class="Oval-2-Copy-12" cx="48" cy="48" r="48" fill="#F74018" />
								<text x="13" y="58" font-family="Formular" font-size="20px" fill="white">Frontera</text></a>
							</g>
							<g class="new-button" transform="translate(15 50)">
								<title>Victoria I</title>
                                <a xlink:href="Resumen.aspx?us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>&p=Victoria%20I">
								<circle class="Oval-2-Copy-11" cx="48" cy="48" r="48" fill="#ff751a" />
								<text x="3" y="58" font-family="Arial" font-size="25px" fill="white">Victoria I</text></a>
							</g>
							<g class="new-button" transform="translate(-40 300)">
								<title>Nuevo Laredo I</title>
                                <a xlink:href="Resumen.aspx?us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>&p=Nuevo%20Laredo%20I">
								<circle class="Oval-2-Copy-13" cx="48" cy="48" r="48" fill="#ff751a" />
								<text x="-35" y="58" font-family="Arial" font-size="25px" fill="white">Nuevo Laredo I</text></a>
							</g>
							<g class="new-button" transform="translate(-130 397)">
								<title>Nuevo Laredo II</title>
                                <a xlink:href="Resumen.aspx?us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>&p=Nuevo%20Laredo%20II">
								<circle class="Oval-2-Copy-12" cx="48" cy="48" r="48" fill="#ff751a" />
								<text x="-40" y="58" font-family="Arial" font-size="25px" fill="white">Nuevo Laredo II</text></a>
							</g>
							<g class="new-button" transform="translate(-225 457)">
								<title>Nuevo Laredo III</title>
                                <a xlink:href="Resumen.aspx?us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>&p=Nuevo%20Laredo%20III">
								<circle class="Oval-2-Copy-12" cx="48" cy="48" r="48" fill="#F74018" />
								<text x="-40" y="58" font-family="Arial" font-size="25px" fill="white">Nuevo Laredo III</text></a>
							</g>
							<g class="new-button" transform="translate(-40 -75)">
								<title>Guadalupe III</title>
                                <a xlink:href="Resumen.aspx?us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>&p=Guadalupe%20III">
								<circle class="Oval-2-Copy-12" cx="48" cy="48" r="48" fill="#ff751a" />
								<text x="-24" y="58" font-family="Arial" font-size="25px" fill="white">Guadalupe III</text></a>
							</g>
							<g class="new-button" transform="translate(-160 -175)">
								<title>Linares</title>
                                <a xlink:href="Resumen.aspx?us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>&p=Linares">
								<circle class="Oval-2-Copy-12" cx="48" cy="48" r="48" fill="#ff751a" />
								<text x="13" y="58" font-family="Arial" font-size="25px" fill="white">Linares</text></a>
							</g>
							<g class="new-button" transform="translate(15 180)">
								<title>Victoria II</title>
                                <a xlink:href="Resumen.aspx?us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>&p=Victoria%20II">
								<circle class="Oval-2-Copy-12" cx="48" cy="48" r="48" fill="#ff751a" />
								<text x="0" y="58" font-family="Arial" font-size="25px" fill="white">Victoria II</text></a>
							</g>
						</g>
						<g class="home-menu" transform="translate(229 18)">
							<g class="portfolio-button" transform="translate(119)">
								<title>RBE V</title>
                                <a xlink:href="Resumen.aspx?us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>&p=RBE%20V">
								<circle class="Oval-2-Copy-4" cx="48" cy="48" r="48" fill="#ff751a" />
								<text x="12" y="58" font-family="Arial" font-size="25px" fill="white">RBE V</text></a>
							</g>
							<g class="portfolio-button" transform="translate(0 23)">
								<title>RBE IV</title>
                                <a xlink:href="Resumen.aspx?us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>&p=RBE%20IV">
								<circle class="Oval-2-Copy-6" cx="48" cy="48" r="48" fill="#ff751a" />
								<text x="9" y="58" font-family="Arial" font-size="25px" fill="white">RBE IV</text></a>
							</g>
							<g class="portfolio-button" transform="translate(239 23)">
								<title>RBE IX</title>
                                <a xlink:href="Resumen.aspx?us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>&p=RBE%20IX">
								<circle class="Oval-2-Copy-5" cx="48" cy="48" r="48" fill="#ff751a" />
								<text x="9" y="58" font-family="Arial" font-size="25px" fill="white">RBE IX</text></a>
							</g>
							<g class="portfolio-button" transform="translate(330 80)">
								<title>RBE X</title>
                                <a xlink:href="Resumen.aspx?us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>&p=RBE X">
								<circle class="Oval-2-Copy-5" cx="48" cy="48" r="48" fill="#ff751a" />
								<text x="9" y="58" font-family="Arial" font-size="25px" fill="white">RBE X</text></a>
							</g>
							<g class="portfolio-button" transform="translate(370 140)">
								<title>MECA</title>
                                <a xlink:href="Resumen.aspx?us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>&p=MECA">
								<circle class="Oval-2-Copy-5" cx="48" cy="48" r="48" fill="#ff751a" />
								<text x="9" y="58" font-family="Arial" font-size="25px" fill="white">MECA</text></a>
							</g>
						</g>
						<g class="settings-menu" transform="translate(228 654)">
							<g class="profile-button" transform="translate(50 20)">
								<title>Zacatecas II</title>
                                <a xlink:href="Resumen.aspx?us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>&p=Zacatecas%20II">
								<circle class="Oval-2-Copy-8" cx="48" cy="48" r="48" fill="#ff751a" />
								<text x="-15" y="58" font-family="Arial" font-size="25px" fill="white">Zacatecas II</text></a>					
							</g>
							<g class="profile-button" transform="translate(-60 -30)">
								<title>Zacatecas I</title>
                                <a xlink:href="Resumen.aspx?us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>&p=Zacatecas%20I">
								<circle class="Oval-2-Copy-9" cx="48" cy="48" r="48" fill="#ff751a" />
								<text x="-13" y="58" font-family="Arial" font-size="25px" fill="white">Zacatecas I</text></a>
							</g>
							<g class="profile-button" transform="translate(190 20)">
								<title>Fresnillo I</title>
                                <a xlink:href="Resumen.aspx?us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>&p=Fresnillo%20I">
								<circle class="Oval-2-Copy-10" cx="48" cy="48" r="48" fill="#ff751a" />
								<text x="-3" y="58" font-family="Arial" font-size="25px" fill="white">Fresnillo I</text></a>
							</g>
							<g class="profile-button" transform="translate(300 -30)">
								<title>Fresnillo II</title>
                                <a xlink:href="Resumen.aspx?us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>&p=Fresnillo%20II">
								<circle class="Oval-2-Copy-10" cx="48" cy="48" r="48" fill="#ff751a" />
								<text x="-5" y="58" font-family="Arial" font-size="25px" fill="white">Fresnillo II</text></a>
							</g>
							<g class="profile-button" transform="translate(390 -120)">
								<title>Fresnillo III</title>
                                <a xlink:href="Resumen.aspx?us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>&p=Fresnillo%20III">
								<circle class="Oval-2-Copy-10" cx="48" cy="48" r="48" fill="#ff751a" />
								<text x="-15" y="55" font-family="Arial" font-size="25px" fill="white">Fresnillo III</text></a>
							</g>
						</g>
						<g class="faq-menu" transform="translate(18 229)">
							<g class="writing-button" transform="translate(70 -100)">
								<title>Durango I</title>
                                <a xlink:href="Resumen.aspx?us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>&p=Durango%20I">
								<circle class="Oval-2-Copy-7" cx="48" cy="48" r="48" fill="#ff751a" />
								<text x="-5" y="58" font-family="Arial" font-size="25px" fill="white">Durango I</text></a>
							</g>
							<g class="writing-button" transform="translate(24 -20)">
								<title>Durango II</title>
                                <a xlink:href="Resumen.aspx?us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>&p=Durango%20II">
								<circle class="Oval-2-Copy-7" cx="48" cy="48" r="48" fill="#ff751a" />
								<text x="-8" y="58" font-family="Arial" font-size="25px" fill="white">Durango II</text></a>
							</g>
							<g class="writing-button" transform="translate(0 60)">
								<title>Guamuchil</title>
                                <a xlink:href="Resumen.aspx?us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>&p=Guamuchil">
								<circle class="Oval-2-Copy-7" cx="48" cy="48" r="48" fill="#ff751a" />
								<text x="-10" y="58" font-family="Arial" font-size="25px" fill="white">Guamuchil</text></a>
							</g>
							<g class="writing-button" transform="translate(0 120)">
								<title>Meoqui</title>
								<a xlink:href="Resumen.aspx?us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>&p=Meoqui">
								<circle class="Oval-2-Copy-7" cx="48" cy="48" r="48" fill="#ff751a" />
								<text x="9" y="58" font-family="Arial" font-size="25px" fill="white">Meoqui</text></a>
							</g>
							<g class="writing-button" transform="translate(22 200)">
								<title>Mochis</title>
                                <a xlink:href="Resumen.aspx?us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>&p=Mochis">
								<circle class="Oval-2-Copy-7" cx="48" cy="48" r="48" fill="#ff751a" />
								<text x="10" y="58" font-family="Arial" font-size="25px" fill="white">Mochis</text></a>
							</g>
							<g class="portfolio-button" transform="translate(45 280)">
								<title>Parral</title>
								<a xlink:href="Resumen.aspx?us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>&p=Parral">
								<circle class="Oval-2-Copy-5" cx="48" cy="48" r="48" fill="#ff751a" />
								<text x="12" y="58" font-family="Arial" font-size="25px" fill="white">Parral</text></a>
							</g>
						</g>
					</g>
					<g class="middle-layer" transform="translate(132 132)">
						<circle class="middle-circle-backgroud" cx="264" cy="264" r="264" fill="#000" fill-opacity=".4"/>
						<g class="button-group">
							<g class="settings-button" transform="translate(216 408)">
								<title>Central</title>
								<circle class="Oval-2-Copy-3" cx="48" cy="48" r="48" fill="#ff751a"/>
								<text x="8" y="58" font-family="Arial" font-size="25px" fill="white">Central</text>							
							</g>
							<g class="faq-button" transform="translate(-10 217)">
								<title>North West</title>
								<circle class="Oval-2-Copy" cx="48" cy="48" r="48" fill="#ff751a"/>
								<text x="16" y="58" font-family="Arial" font-size="25px" fill="white">North West</text>
							</g>
							<g class="home-button" transform="translate(216 27)">
								<title>North</title>
								<circle class="Oval-2-Copy-2" cx="48" cy="48" r="48" fill="#ff751a"/>
								<text x="17" y="58" font-family="Arial" font-size="25px" fill="white">North</text>							
							</g>
							<g class="more-button" transform="translate(365 217)">
								<title>North East</title>
								<circle class="Oval-2" cx="48" cy="48" r="48" fill="#ff751a" />
								<text x="25" y="58" font-family="Arial" font-size="25px" fill="white">North East</text>							
							</g>
						</g>
					</g>
					<g class="main-menu" transform="translate(276 276)">
						<title>Disciplinas Operacionales</title>
						<circle class="inner-circle-background" cx="120" cy="120" r="120" fill="#000" opacity=".4"/>
						<g class="menu-button" fill="#fff" fill-rule="nonzero" transform="translate(84 95)">
							<text x="-27" y="18" font-family="Arial" font-size="27px" fill="white">Disciplinas</text>
                            <text x="-52" y="50" font-family="Arial" font-size="27px" fill="white">Operacionales</text>
						</g>
					</g>
				</g>
			</g>
		</svg>
	</div>

                <!--****** PIE DE PAGINA ******-->
                <footer class="footer" style="left: 0px;">
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
<script src='js/jQueryRadius.js'></script>
	<script src='js/TweenMax.min.js'></script>
	<script src='js/scripts.js' type='text/javascript'></script>
	<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-36251023-1']);
  _gaq.push(['_setDomainName', 'jqueryscript.net']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>
</html>
