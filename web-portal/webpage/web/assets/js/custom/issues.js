var clients = [
    {"Name": "Otto Clay", "Age": 25, "Country": 1, "Address": "Ap #897-1459 Quam Avenue", "Married": false},
    {"Name": "Connor Johnston", "Age": 45, "Country": 2, "Address": "Ap #370-4647 Dis Av.", "Married": true},
    {"Name": "Lacey Hess", "Age": 29, "Country": 3, "Address": "Ap #365-8835 Integer St.", "Married": false},
    {"Name": "Timothy Henson", "Age": 56, "Country": 1, "Address": "911-5143 Luctus Ave", "Married": true},
    {"Name": "Ramona Benton", "Age": 32, "Country": 3, "Address": "Ap #614-689 Vehicula Street", "Married": false}
];

var countries = [
    {Name: "", Id: 0},
    {Name: "United States", Id: 1},
    {Name: "Canada", Id: 2},
    {Name: "United Kingdom", Id: 3}
];

$("#jsGrid").jsGrid({
    width: "100%",
    height: "600px",
    sorting: true,
    paging: true,
    autoload: true,
    noDataContent: "No han habido incidencias",
    loadMessage: "Recopilando listado...",
    updateOnResize: true,
    loadIndication: true,
    pagePrevText: "Anterior",
    pageNextText: "Siguiente",
    pageFirstText: "Primera",
    pageLastText: "Ultima",
    loadIndicationDelay: 500,
    loadShading: true,
    controller: {
        loadData: function () {
            var d = $.Deferred();
            firebase.database().ref('/notifications/read').once('value').then(function (snapshot) {
                notifications = snapshot.val()
                var data = []
                Object.keys(notifications).forEach(function (key) {
                    value = notifications[key]
                    var row = {}
                    row['Identificacion'] = key
                    row['Tipo'] = value.type
                    row['Robot'] = value.robot
                    row['Mensaje'] = value.message
                    row['Supervisor'] = value.supervisor
                    var date = new Date(value.date);
                    var seconds = date.getSeconds();
                    var minutes = date.getMinutes();
                    var hour = date.getHours();

                    var year = date.getFullYear();
                    var month = date.getMonth(); // beware: January = 0; February = 1, etc.
                    var day = date.getDate();
                    row['epoch'] = value.date
                    row['Hora'] = (hour < 10 ? ('0' + hour) : hour) + ':' + (minutes < 10 ? '0' + minutes : minutes) + ':' + (seconds < 10 ? '0' + seconds : seconds)
                    row['Fecha'] = (day < 10 ? '0' + day : day) + '/' + (month < 10 ? '0' + month : month) + '/' + year
                    data.push(row)
                });
                data.sort(function (a, b) {
                    return b['epoch'] - a['epoch']
                })
                d.resolve(data);
            });
            return d.promise();
        }
    },
    invalidNotify: function (args) {
        $('#alert-error-not-submit').removeClass('hidden');
        console.log('Hey')
    },
    fields: [
        {name: "Identificacion", type: "text"},
        {name: "Tipo", type: "text", itemTemplate: function(value, item) {
                switch (value) {
                    case 1:
                        return $('<div style="text-align: center"><span class="label label-danger">Critico</span></div>');
                    case 2:
                        return $('<div style="text-align: center"><span class="label label-warning">Advertencia</span></div>');
                    case 3:
                        return $('<div style="text-align: center"><span class="label label-info">Informativo</span></div>');
                    case 4:
                        return $('<div style="text-align: center"><span class="label label-success">Éxito</span></div>');
                    default:
                        return $('');
                }
            },

        },
        {name: "Robot", type: "number"},
        {name: "Mensaje", type: "text"},
        {name: "Supervisor", type: "text"},
        {name: "Hora", type: "text"},
        {name: "Fecha", type: "text"}
    ]
});



