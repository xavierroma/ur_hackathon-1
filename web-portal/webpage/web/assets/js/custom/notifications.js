
var first_read = true
var read_status = 1
var unread_notifications = null

function updateNotifications(notificationList) {
    unread_notifications = notificationList
    $('#notification-center').empty()
    values = 0
    heartbit = 0
    received_notifications = []
    if (notificationList !== null) {
        Object.keys(notificationList).forEach(function (key) {
            value = notificationList[key]
            Push.create(value.causer,{
                body: value.reason ,
                icon: '/assets/images/logo.png',
                timeout: 2000,
                onClick: function () {
                    window.focus();
                    this.close();
                }
            });
            values++
            received_notifications.push(value)
        });
        received_notifications.sort(function (a, b) {
            return b.date - a.date
        })
        for (let i = 0; i < received_notifications.length && i < 5; i++) {
            $('#notification-center').append('<a href="#">\n' +
                '    <div class="mail-list">\n' +
                '    <h5>' + received_notifications[i].causer + ' </h5>\n' +
                '<span class="label label-danger">' + received_notifications[i].reason + '</span>\n' +
                '</div>\n' +
                '</a>')
        }
        $('#number-notifications').empty()
        if (values == 1) {
            $('#number-notifications').append('Tienes ' + values + ' aviso')
        } else {
            $('#number-notifications').append('Tienes ' + values + ' avisos')
        }
        $('#heartbitDiv').empty()
        $('#heartbitDiv').append('<span class="heartbit"></span><span class="point"></span>')
    } else {
        $('#number-notifications').empty()
        $('#number-notifications').append('Tienes 0 avisos')
    }
}

var starCountRef = firebase.database().ref('notifications/read_status');
starCountRef.on('value', function (snapshot) {
    if (snapshot.val() === 0) {
        firebase.database().ref('/notifications/unread').once('value').then(function (snapshot) {
            updateNotifications(snapshot.val())
        });
        read_status = 0
    }
});

$("#notify-bubble").on("click", function () {
    if (read_status == 0) {
        firebase.database().ref('/notifications/read_status').set(1);
        $('#heartbitDiv').empty()
        read_status = 1
        if (unread_notifications !== null) {
            Object.keys(unread_notifications).forEach(function (key) {
                value = unread_notifications[key]
                firebase.database().ref('/notifications/unread/' + key).remove();
                firebase.database().ref('notifications/read').push({
                    reason: value.reason,
                    causer: value.causer,
                    date: value.date
                });
            });
            unread_notifications = null
        }
    }
})

/*
function handleStatusBit(safety) {
   toShow = ""
   switch (safety) {
       case "1028":
           Push.create("Robot #WG758 ",{
               body: "Esta en parada de proteccion, necesita atencion",
               icon: '/assets/images/logo.png',
               timeout: 2000,
               onClick: function () {
                   window.focus();
                   this.close();
               }
           });
           break;
       case "1216":
           Push.create("Robot #WG758 ",{
               body: "Esta en parada de emergencia! Necesita atencion immediata",
               icon: '/assets/images/logo.png',
               timeout: 2000,
               onClick: function () {
                   window.focus();
                   this.close();
               }
           });
           break;
       case "1536":
           Push.create("Robot #WG758 ",{
               body: "Error critico, por favor consulta la interficie para mas informacion",
               icon: '/assets/images/logo.png',
               timeout: 2000,
               onClick: function () {
                   window.focus();
                   this.close();
               }
           });
           break;
       case "1":
           Push.create("Robot #WG758 ",{
               body: "Se ha recuperado y esta de nuevo en modo normal",
               icon: '/assets/images/logo.png',
               timeout: 2000,
               onClick: function () {
                   window.focus();
                   this.close();
               }
           });
           break;
   }
}*/