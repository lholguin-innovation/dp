<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Registro.aspx.cs" Inherits="Registro" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Disciplinas Operacionales Registro</title>
    <meta charset="utf-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>

    <link href="css/bootstrap.min.css" rel="stylesheet"/>
    <script src="js/bootstrap.min.js"></script>
    <script src="js/sweetalert.min.js"></script>
    <script src="js/jquery.min.js"></script>
    <script src="js/sweetalert.js"></script>
    <style>
        body {
            font-family: 'Arial';
            background: url(img/disciplinas.jpg) no-repeat center center fixed;
            -webkit-background-size: cover;
            -moz-background-size: cover;
            -o-background-size: cover;
            background-size: cover;
            font-weight: 100;
        }
        .panel {
            background-color: transparent;
            border-color: gray;
            color: white;
            box-shadow: 3px 5px 20px 5px rgba(0, 0, 0, 0.5);
        }
        .panel-black > .panel-heading {
            background-color: #303030;
        }
        .panel-black > .panel-body {
            background-color: rgba(0,0,0,0.5);
        }
        .control-label {
             color: white;
             font-weight: 100;
        }
        .btn, .form-control {
            font-weight: 100;
        }
        @media (min-width: 1200px) {
        .panel {
            margin-top: 30%; margin-bottom: 30%; } }
        @media (min-width: 992px) and (max-width: 1199.98px) {
        .panel {
            margin-top: 20%; margin-bottom: 20%; } }
        @media (min-width: 768px) and (max-width: 991.98px) {
        .panel {
            margin-top: 10%; margin-bottom: 10%; } }
        @media (max-width: 767.98px) {
        .panel {
            margin-top: 5%; margin-bottom: 5%; } }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <div class="row">
                <div class="col-sm-offset-4 col-sm-4 col-sm-offset-4">
                    <div class="panel panel-black">
                        <div class="panel-heading text-center">
                            <div class="row">
                                <div class="col-sm-12">
                                    <label class="control-label" style="font-size: 20px;"><span class="glyphicon glyphicon-user"></span>&nbsp; Registrar Usuario</label>
                                </div>
                            </div>
                        </div>
                        <div class="panel-body" style="background-color: rgba(0,0,0,0.5);">
                            <div class="col-sm-12">
                                <label class="control-label">Nombre</label>
                                <asp:TextBox ID="txtNombre" CssClass="form-control" runat="server" ForeColor="Black" Font-Size="Medium"></asp:TextBox>
                                <br />
                            </div>
                            <div class="col-sm-12">
                                <label class="control-label">Planta</label>
                                <asp:DropDownList ID="ddlPlanta" CssClass="form-control" ForeColor="Black" Font-Size="Medium" runat="server"></asp:DropDownList>
                                <br />
                            </div>
                            <div class="col-sm-12">
                                <label class="control-label">Area</label>
                                <asp:DropDownList ID="ddlArea" CssClass="form-control" ForeColor="Black" Font-Size="Medium" runat="server"></asp:DropDownList>
                                <br />
                            </div>
                            <div class="col-sm-12">
                                <label class="control-label">NetID</label>
                                <asp:TextBox ID="txtNetID" CssClass="form-control" runat="server" ForeColor="Black" Font-Size="Medium" placeholder="Ej: qj2mcc"></asp:TextBox>
                                <br />
                            </div>
                            <div class="col-sm-12">
                                <label class="control-label">Email</label>
                                <asp:TextBox ID="txtEmail" CssClass="form-control" runat="server" ForeColor="Black" Font-Size="Medium" placeholder="ejemplo@aptiv.com" onkeypress="return EnterEvent(event)"></asp:TextBox>
                                <br /><br />
                            </div>
                            <div class="col-sm-12">
                                <asp:Button ID="btnRegresar" CssClass="pull-left btn btn-danger" runat="server" Text="Regresar" UseSubmitBehavior="False" OnClientClick="javascript:window.location.replace('Default.aspx'); return false;" />
                                <asp:Button ID="btnGuardar" CssClass="pull-right btn btn-success" runat="server" Text="Guardar" UseSubmitBehavior="False" OnClick="btnGuardar_Click" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <asp:Literal ID="litmensaje" runat="server"></asp:Literal>
    </form>
</body>
</html>
