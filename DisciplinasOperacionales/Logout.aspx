<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Logout.aspx.cs" Inherits="Logout" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>MCI - Login</title>
    <meta charset="utf-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>

    <link href="css/bootstrap.min.css" rel="stylesheet"/>
    <script src="js/bootstrap.min.js"></script>
    <script src="js/sweetalert.min.js"></script>
    <script src="js/jquery.min.js"></script>
    <script src="js/sweetalert.js"></script>
    <style>
		@font-face
		{
			font-family: Formular;
			src: url(Formular.ttf);
		}
        body {
            font-family: Formular;
            background: url(img/downtime.jpg) no-repeat center center fixed;
            -webkit-background-size: cover;
            -moz-background-size: cover;
            -o-background-size: cover;
            background-size: cover;
            font-weight: 100;
        }
        .animated-central {
            -webkit-animation-duration: 2s;
            animation-duration: 2s;
            -webkit-animation-fill-mode: both;
            animation-fill-mode: both;
        }
        @-webkit-keyframes fadeInCentral {
            0% {
               opacity: 0;
               -webkit-transform: translateY(10px);
            }
            100% {
               opacity: 1;
               -webkit-transform: translateY(0);
            }
         }
         @keyframes fadeInCentral {
            0% {
               opacity: 0;
               transform: translateY(10px);
            }
            100% {
               opacity: 1;
               transform: translateY(0);
            }
         }
         .fadeInCentral {
            -webkit-animation-name: fadeInCentral;
            animation-name: fadeInCentral;
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
        <asp:Literal ID="litmensaje" runat="server"></asp:Literal>
    </form>
</body>
<script> 
</script>
</html>
