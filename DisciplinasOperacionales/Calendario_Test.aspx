<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Calendario_Test.aspx.cs" Inherits="Calendario_Test" %>

<!DOCTYPE html>

<html class="no-js" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="x-ua-compatible" content="ie=edge" />
    <title> Agenda </title>
		
    <meta name="description" content="" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link rel="apple-touch-icon" href="apple-touch-icon.png" />

    <link rel="stylesheet" href="css/vendor.css" />
	<link rel="stylesheet" id="theme_style" href="css/app.css" />
	<link rel="stylesheet" type="text/css" href="css/dataTables.bootstrap4.min.css" />
    <link rel="stylesheet" type="text/css" href="css/fullcalendar.min.css" />  

	<script src="js/jquery-3.3.1.js"></script>
	<script src="js/vendor.js"></script>
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
        #calendar {
          max-width: 900px;
          margin: 40px auto;
        }
        .list-group-item {
            background-color: transparent;
        }
        .tooltip {
          position: relative;
          display: inline-block;
          border-bottom: 1px dotted black;
        }
        .tooltip .tooltiptext {
          visibility: hidden;
          width: 120px;
          background-color: black;
          color: #fff;
          text-align: center;
          border-radius: 6px;
          padding: 5px 0;

          position: absolute;
          z-index: 1;
        }
        .tooltip:hover .tooltiptext {
          visibility: visible;
        }
        .text-orange {
            color: #ff8c1a;
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
                        <div class="name">Disciplinas Operacionales</div>
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
                                <li>
                                    <a href="Reportes.aspx?us=<%=lblUsuario.Text %>&nombre=<%=lblNombre.Text %>&p=<%=lblPlanta.Text %>">
                                        <i class="fa fa-bar-chart"></i> Reportes
                                    </a>
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
                                <li class="active">
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
                        <h2 class="title"> Agenda <%=lblPlanta.Text %> </h2>
                    </div>
                    <section class="section">
                        <div class="row">
                            <div class="col-sm-12">
                                <div id='calendar'></div>
                            </div>
                            <div class="col-sm-12">
                                <input type="button" id="btnEliminar" runat="server" style="visibility: hidden" onserverclick="btnEliminar_Click" />
                                <input type="hidden" id="txtAgenda" name="txtAgenda" value="" />
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-sm-12">
                                <asp:literal ID="litURL" runat="server"></asp:literal>
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

        <!--************** MODAL **************-->
	    <div class="modal fade" id="myModal" role="dialog" style="margin-top: 60px">
		    <div class="modal-dialog">
			    <!-- Modal content-->
			    <div class="modal-content" >
				    <div class="modal-header">
                                <h3>Agendar evaluaci&oacute;n</h3>
				        <button type="button" class="close" style="color: white" data-dismiss="modal">&times;</button>
				    </div>
                    <div class="row">
                        <div class="col-sm-12">
                            <div  class="modal-body" id="modal_body">
				                <div class="tab-content">
                                    <div role="tabpanel" class="tab-pane fade in active show" id="agenda">
                                        <div class="row">
                                            <div class="col-sm-6">
                                                <label class="control-label" for="txtFh">Fecha</label>
                                                <input type="date" class="form-control" id="txtFh" name="txtFh" />
                                            </div>
                                            <div class="col-sm-6">
                                                <label class="control-label" for="txtHora">Hora</label>
                                                <input type="time" class="form-control" id="txtHora" name="txtHora" />
                                            </div>
                                        </div>
                                        <br />
                                        <div class="row">
                                            <div class="col-sm-6">
                                                <label class="control-label" for="ddlArea">&Aacute;rea</label>
                                                <asp:DropDownList ID="ddlArea" CssClass="form-control" runat="server"></asp:DropDownList>
                                            </div>
                                        </div>
                                        <br />
                                        <div class="row">
                                            <div class="col-sm-12">
                                                <label class="control-label" for="txtMensaje">Mensaje (opcional)</label>
                                                <input type="text" id="txtMensaje" class="form-control" name="txtMensaje" maxlength="300"/>
                                            </div>
                                        </div>
                                    </div>
                                </div>
				            </div>
                        </div>
                    </div>			    
				    <div class="modal-footer">
                        <asp:Button CssClass="btn btn-success" ID="btnAgendar" runat="server" Text="Agendar" OnClick="btnAgendar_Click" />
				        <button type="button" class="btn btn-danger" data-dismiss="modal">Cerrar</button>
				    </div>
			    </div>
			</div>
	    </div>
        <!--***********************************-->
    </form>
</body>
<script src="js/moment.min.js"></script>
<script src="js/fullcalendar.min.js"></script>
<script src="js/popper.min.js"></script>
<script src="js/es.js"></script>
<script>
    $(function () {
        $('#calendar').fullCalendar({
            aspectRatio: 2,
            themeSystem: 'standard',
            eventLimit: 4,
            weekNumbers: true,
            header: {
                left: 'prev,next today',
                center: 'title',
                right: 'month'
            },
            showNonCurrentDates: false,
            events: [ <%=eventos%>],
            eventRender: function (event, element) {
                element.popover({
                    title: '<i style="color: ' + event.color + '" class="fa fa-square"></i>' + event.title,
                    content: event.description,
                    trigger: 'manual',
                    html: true,
                    placement: 'top',
                    container: 'body'
                }).on('mouseenter', function () {
                    var _this = this;
                    $(this).popover('show');
                    $('.popover').on('mouseleave', function () {
                        $(_this).popover('hide');
                    });
                }).on('mouseleave', function () {
                    var _this = this;
                    setTimeout(function () {
                        if (!$('.popover:hover').length) {
                            $(_this).popover('hide');
                        }
                    }, 300);
                });

                if (event.icon) {
                    element.find(".fc-title").prepend("<i class='fa fa-" + event.icon + "'></i>");
                    //time (tacha), check (palomita), clock-o (pendiente)
                }
            },
            dayClick: function (date, jsEvent, view) {
                document.getElementById('txtFh').value = date.format('YYYY-MM-DD');
                $("#myModal").modal();
            }
        });
    });

    function EliminarAgenda(id) {
        swal({
            title: "Cuidado!",
            text: "Estás a punto de eliminar esta fecha agendada, deseas continuar?",
            type: "warning",
            showCancelButton: true,
            confirmButtonClass: 'btn-success',
            confirmButtonText: "Eliminar",
            cancelButtonText: "Cerrar",
            closeOnConfirm: false,
            closeOnCancel: false
        },
        function (isConfirm) {
            if (isConfirm) {
                document.getElementById("txtAgenda").value = id;
                $('#btnEliminar').trigger('click');
            }
            else {
                swal.close();
            }
        });
    }
</script>
</html>
