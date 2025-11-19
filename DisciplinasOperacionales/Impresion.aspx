<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Impresion.aspx.cs" Inherits="Impresion" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
	<meta charset="utf-8" />
    <meta http-equiv="x-ua-compatible" content="ie=edge" />
		
    <meta name="description" content="" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link rel="apple-touch-icon" href="apple-touch-icon.png" />
    <link rel="stylesheet" href="css/vendor.css" />
	<link rel="stylesheet" type="text/css" href="css/dataTables.bootstrap4.min.css" />
	<style>
		body {
			font-family: 'Segoe UI Light';
			font-weight: 600;
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
		tbody {
			font-size: 19px;
		}
		thead {
			font-size: 20px;
            font-weight: 100;
		}
		table {
		  width: 100%;
		  font-weight: 100;
		  max-width: 100%;
		  margin-bottom: 1rem;
		  border: 1px solid #a8b3bd;
		}

		th, td {
		  padding: 0.3rem;
		  vertical-align: top;
		}

		@media print {
		  @page { margin: 0; }
		}
        .text-orange {
            color: #ff6600;
        }
	</style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container-fluid">
            <br />
		    <div class="row">
			    <div class="col-sm-12">
				    <div class='title-block'>
					    <img src='img/delphi.png' width='150' height='35'/><h5 class='title pull-right'><%=Request["planta_sel"].ToString()%> &nbsp;&nbsp;&nbsp;&nbsp; Realizo: <%=realizo %> &nbsp;&nbsp;&nbsp;&nbsp; <%=fecha %> </h5>
				    </div>
			    </div>
		    </div>
            <br />
            <div class="title-block text-center">
                <h4 class="title"> Disciplinas Operacionales </h4>
            </div>
            <div class="title-block">
                <h4 class="title"> Evaluaci&oacute;n </h4>
            </div>
            <hr/>
            <div class="row">
                <asp:Literal ID="litEvaluacion" runat="server"></asp:Literal>
            </div>
            <div class="title-block">
                <h4 class="title"> Resultados </h4>
            </div>
            <hr/>
            <div class="row">
                <asp:Literal ID="litResultado" runat="server"></asp:Literal>
            </div>
            <br />
            <div class="title-block">
                <h4 class="title"> Planes de acci&oacute;n </h4>
            </div>
            <hr/>
            <div class="row">
                <asp:Literal ID="litPlanes" runat="server"></asp:Literal>
            </div>
        </div>
    </form>
</body>
<script>
    window.print();
    window.onafterprint = function () {
        window.close(); window.location.href = "Historial.aspx?us=<%=Request["us"].ToString()%>&nombre=<%=Request["nombre"].ToString()%>&p=<%=Request["planta_us"].ToString()%>";
    }
</script>
</html>
