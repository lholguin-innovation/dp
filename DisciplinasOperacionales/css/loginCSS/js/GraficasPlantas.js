
google.charts.load('current', { 'packages': ['corechart'] });

google.charts.setOnLoadCallback(drawChart1);
function drawChart1() {
    var data = google.visualization.arrayToDataTable([
        ['PBP', 'Cantidad'],
        ['NI', <%=NI[0]%>],
        ['ME', <%=ME[0]%>],
        ['U', <%=U[0]%>],
        ['EE', <%=EE[0]%>],
        ['O', <%=O[0]%>]]);
    var options = {
        titleTextStyle: {
            fontName: 'Segoe UI Light', // i.e. 'Times New Roman'
            fontSize: 16, // 12, 18 whatever you want (don't specify px)
        },
        title: '<%=nombrePlanta[0]%>',
        width: 550,
        height: 350,
        colors: ['#00a3cc', '#e67300', '#b3b3b3', '#e6b800', '#006bb3'],
        backgroundColor: {
            fill: '#ffffff',
            fillOpacity: 0.0
        },
        fontSize: 11
    };
    var chart = new google.visualization.PieChart(document.getElementById('chartPBPPlanta1'));
    chart.draw(data, options);
}

google.charts.setOnLoadCallback(drawChart2);
function drawChart2() {
    var data = google.visualization.arrayToDataTable([
        ['PBP', 'Cantidad'],
        ['NI', <%=NI[1]%>],
        ['ME', <%=ME[1]%>],
        ['U', <%=U[1]%>],
        ['EE', <%=EE[1]%>],
        ['O', <%=O[1]%>]]);
    var options = {
        titleTextStyle: {
            fontName: 'Segoe UI Light', // i.e. 'Times New Roman'
            fontSize: 16, // 12, 18 whatever you want (don't specify px)
        },
        title: '<%=nombrePlanta[1]%>',
        width: 550,
        height: 350,
        colors: ['#00a3cc', '#e67300', '#b3b3b3', '#e6b800', '#006bb3'],
        backgroundColor: {
            fill: '#ffffff',
            fillOpacity: 0.0
        },
        fontSize: 11
    };
    var chart = new google.visualization.PieChart(document.getElementById('chartPBPPlanta2'));
    chart.draw(data, options);
}

google.charts.setOnLoadCallback(drawChart3);
function drawChart3() {
    var data = google.visualization.arrayToDataTable([
        ['PBP', 'Cantidad'],
        ['NI', <%=NI[2]%>],
        ['ME', <%=ME[2]%>],
        ['U', <%=U[2]%>],
        ['EE', <%=EE[2]%>],
        ['O', <%=O[2]%>]]);
    var options = {
        titleTextStyle: {
            fontName: 'Segoe UI Light', // i.e. 'Times New Roman'
            fontSize: 16, // 12, 18 whatever you want (don't specify px)
        },
        title: '<%=nombrePlanta[2]%>',
        width: 550,
        height: 350,
        colors: ['#00a3cc', '#e67300', '#b3b3b3', '#e6b800', '#006bb3'],
        backgroundColor: {
            fill: '#ffffff',
            fillOpacity: 0.0
        },
        fontSize: 11
    };
    var chart = new google.visualization.PieChart(document.getElementById('chartPBPPlanta3'));
    chart.draw(data, options);
}

google.charts.setOnLoadCallback(drawChart4);
function drawChart4() {
    var data = google.visualization.arrayToDataTable([
        ['PBP', 'Cantidad'],
        ['NI', <%=NI[3]%>],
        ['ME', <%=ME[3]%>],
        ['U', <%=U[3]%>],
        ['EE', <%=EE[3]%>],
        ['O', <%=O[3]%>]]);
    var options = {
        titleTextStyle: {
            fontName: 'Segoe UI Light', // i.e. 'Times New Roman'
            fontSize: 16, // 12, 18 whatever you want (don't specify px)
        },
        title: '<%=nombrePlanta[3]%>',
        width: 550,
        height: 350,
        colors: ['#00a3cc', '#e67300', '#b3b3b3', '#e6b800', '#006bb3'],
        backgroundColor: {
            fill: '#ffffff',
            fillOpacity: 0.0
        },
        fontSize: 11
    };
    var chart = new google.visualization.PieChart(document.getElementById('chartPBPPlanta4'));
    chart.draw(data, options);
}

google.charts.setOnLoadCallback(drawChart5);
function drawChart5() {
    var data = google.visualization.arrayToDataTable([
        ['PBP', 'Cantidad'],
        ['NI', <%=NI[4]%>],
        ['ME', <%=ME[4]%>],
        ['U', <%=U[4]%>],
        ['EE', <%=EE[4]%>],
        ['O', <%=O[4]%>]]);
    var options = {
        titleTextStyle: {
            fontName: 'Segoe UI Light', // i.e. 'Times New Roman'
            fontSize: 16, // 12, 18 whatever you want (don't specify px)
        },
        title: '<%=nombrePlanta[4]%>',
        width: 550,
        height: 350,
        colors: ['#00a3cc', '#e67300', '#b3b3b3', '#e6b800', '#006bb3'],
        backgroundColor: {
            fill: '#ffffff',
            fillOpacity: 0.0
        },
        fontSize: 11
    };
    var chart = new google.visualization.PieChart(document.getElementById('chartPBPPlanta5'));
    chart.draw(data, options);
}

google.charts.setOnLoadCallback(drawChart6);
function drawChart6() {
    var data = google.visualization.arrayToDataTable([
        ['PBP', 'Cantidad'],
        ['NI', <%=NI[5]%>],
        ['ME', <%=ME[5]%>],
        ['U', <%=U[5]%>],
        ['EE', <%=EE[5]%>],
        ['O', <%=O[5]%>]]);
    var options = {
        titleTextStyle: {
            fontName: 'Segoe UI Light', // i.e. 'Times New Roman'
            fontSize: 16, // 12, 18 whatever you want (don't specify px)
        },
        title: '<%=nombrePlanta[5]%>',
        width: 550,
        height: 350,
        colors: ['#00a3cc', '#e67300', '#b3b3b3', '#e6b800', '#006bb3'],
        backgroundColor: {
            fill: '#ffffff',
            fillOpacity: 0.0
        },
        fontSize: 11
    };
    var chart = new google.visualization.PieChart(document.getElementById('chartPBPPlanta6'));
    chart.draw(data, options);
}

google.charts.setOnLoadCallback(drawChart7);
function drawChart7() {
    var data = google.visualization.arrayToDataTable([
        ['PBP', 'Cantidad'],
        ['NI', <%=NI[6]%>],
        ['ME', <%=ME[6]%>],
        ['U', <%=U[6]%>],
        ['EE', <%=EE[6]%>],
        ['O', <%=O[6]%>]]);
    var options = {
        titleTextStyle: {
            fontName: 'Segoe UI Light', // i.e. 'Times New Roman'
            fontSize: 16, // 12, 18 whatever you want (don't specify px)
        },
        title: '<%=nombrePlanta[6]%>',
        width: 550,
        height: 350,
        colors: ['#00a3cc', '#e67300', '#b3b3b3', '#e6b800', '#006bb3'],
        backgroundColor: {
            fill: '#ffffff',
            fillOpacity: 0.0
        },
        fontSize: 11
    };
    var chart = new google.visualization.PieChart(document.getElementById('chartPBPPlanta7'));
    chart.draw(data, options);
}

google.charts.setOnLoadCallback(drawChart8);
function drawChart8() {
    var data = google.visualization.arrayToDataTable([
        ['PBP', 'Cantidad'],
        ['NI', <%=NI[7]%>],
        ['ME', <%=ME[7]%>],
        ['U', <%=U[7]%>],
        ['EE', <%=EE[7]%>],
        ['O', <%=O[7]%>]]);
    var options = {
        titleTextStyle: {
            fontName: 'Segoe UI Light', // i.e. 'Times New Roman'
            fontSize: 16, // 12, 18 whatever you want (don't specify px)
        },
        title: '<%=nombrePlanta[7]%>',
        width: 550,
        height: 350,
        colors: ['#00a3cc', '#e67300', '#b3b3b3', '#e6b800', '#006bb3'],
        backgroundColor: {
            fill: '#ffffff',
            fillOpacity: 0.0
        },
        fontSize: 11
    };
    var chart = new google.visualization.PieChart(document.getElementById('chartPBPPlanta8'));
    chart.draw(data, options);
}

google.charts.setOnLoadCallback(drawChart9);
function drawChart9() {
    var data = google.visualization.arrayToDataTable([
        ['PBP', 'Cantidad'],
        ['NI', <%=NI[8]%>],
        ['ME', <%=ME[8]%>],
        ['U', <%=U[8]%>],
        ['EE', <%=EE[8]%>],
        ['O', <%=O[8]%>]]);
    var options = {
        titleTextStyle: {
            fontName: 'Segoe UI Light', // i.e. 'Times New Roman'
            fontSize: 16, // 12, 18 whatever you want (don't specify px)
        },
        title: '<%=nombrePlanta[8]%>',
        width: 550,
        height: 350,
        colors: ['#00a3cc', '#e67300', '#b3b3b3', '#e6b800', '#006bb3'],
        backgroundColor: {
            fill: '#ffffff',
            fillOpacity: 0.0
        },
        fontSize: 11
    };
    var chart = new google.visualization.PieChart(document.getElementById('chartPBPPlanta9'));
    chart.draw(data, options);
}

google.charts.setOnLoadCallback(drawChart10);
function drawChart10() {
    var data = google.visualization.arrayToDataTable([
        ['PBP', 'Cantidad'],
        ['NI', <%=NI[9]%>],
        ['ME', <%=ME[9]%>],
        ['U', <%=U[9]%>],
        ['EE', <%=EE[9]%>],
        ['O', <%=O[9]%>]]);
    var options = {
        titleTextStyle: {
            fontName: 'Segoe UI Light', // i.e. 'Times New Roman'
            fontSize: 16, // 12, 18 whatever you want (don't specify px)
        },
        title: '<%=nombrePlanta[9]%>',
        width: 550,
        height: 350,
        colors: ['#00a3cc', '#e67300', '#b3b3b3', '#e6b800', '#006bb3'],
        backgroundColor: {
            fill: '#ffffff',
            fillOpacity: 0.0
        },
        fontSize: 11
    };
    var chart = new google.visualization.PieChart(document.getElementById('chartPBPPlanta10'));
    chart.draw(data, options);
}

google.charts.setOnLoadCallback(drawChart11);
function drawChart11() {
    var data = google.visualization.arrayToDataTable([
        ['PBP', 'Cantidad'],
        ['NI', <%=NI[0]%>],
        ['ME', <%=ME[0]%>],
        ['U', <%=U[0]%>],
        ['EE', <%=EE[0]%>],
        ['O', <%=O[0]%>]]);
    var options = {
        titleTextStyle: {
            fontName: 'Segoe UI Light', // i.e. 'Times New Roman'
            fontSize: 16, // 12, 18 whatever you want (don't specify px)
        },
        title: '<%=nombrePlanta[0]%>',
        width: 550,
        height: 350,
        colors: ['#00a3cc', '#e67300', '#b3b3b3', '#e6b800', '#006bb3'],
        backgroundColor: {
            fill: '#ffffff',
            fillOpacity: 0.0
        },
        fontSize: 11
    };
    var chart = new google.visualization.PieChart(document.getElementById('chartPBPPlanta11'));
    chart.draw(data, options);
}