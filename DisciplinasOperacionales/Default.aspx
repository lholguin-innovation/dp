<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="_Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Disciplinas Operacionales Inicio de Sesi&oacute;n</title>
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
            margin-top: 50%; margin-bottom: 50%; } }
        @media (min-width: 992px) and (max-width: 1199.98px) {
        .panel {
            margin-top: 40%; margin-bottom: 40%; } }
        @media (min-width: 768px) and (max-width: 991.98px) {
        .panel {
            margin-top: 30%; margin-bottom: 30%; } }
        @media (max-width: 767.98px) {
        .panel {
            margin-top: 25%; margin-bottom: 25%; } }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <div class="row">
                <div class="col-sm-offset-4 col-sm-4 col-sm-offset-4">
                    <div class="panel panel-black" style="">
                        <div class="panel-heading text-center">
                            <div class="row">
                                <div class="col-sm-12">
                                    <label class="control-label" style="font-size: 20px;"><span class="glyphicon glyphicon-user"></span>&nbsp; Iniciar Sesi&oacute;n</label>
                                </div>
                            </div>
                        </div>
                        <div class="panel-body" style="background-color: rgba(0,0,0,0.5);">
                            <div class="col-sm-12 text-center">
                                <label class="control-label" style="font-size: 45px">Disciplinas Operacionales</label>
                                <br /><br /><br />
                            </div>
                            <div class="col-sm-12">
                                <asp:TextBox ID="txtNetId" CssClass="form-control" runat="server" ForeColor="Black" placeholder="NetId" Font-Size="Medium"></asp:TextBox>
                                <br />
                            </div>
                            <div class="col-sm-12">
                                <asp:TextBox ID="txtPass" CssClass="form-control" runat="server" ForeColor="Black" placeholder="Contraseña" TextMode="Password" Font-Size="Medium" onkeypress="return EnterEvent(event)"></asp:TextBox>
                                <br /><br />
                            </div>
                            <div class="col-sm-12">
                                <asp:Button ID="btnRegistrar" CssClass="pull-left btn btn-primary" runat="server" Text="Registrar" UseSubmitBehavior="False" OnClientClick="javascript:window.location.replace('Registro.aspx'); return false;" />
                                <asp:Button ID="btnEntrar" CssClass="pull-right btn btn-success" runat="server" Text="Entrar" UseSubmitBehavior="False" OnClick="btnEntrar_Click" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <asp:Literal ID="litmensaje" runat="server"></asp:Literal>
    </form>
</body>
<script>
    function EnterEvent(e) {
            if (e.keyCode == 13) {
                __doPostBack('<%=btnEntrar.UniqueID%>', "");
            }
        }
</script>
</html>
