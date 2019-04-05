var ws = new WebSocket("ws://192.168.1.40:30101/");

var temperatures = [];
var voltages = [];
var currents = [];
var oldCurrent = [];
var safety_status = "";

ws.onopen = function () {
    console.log("opened")
};

ws.onmessage = function (event) {
    try {
        console.log(event.data)
        received = JSON.parse(event.data)
        value = JSON.parse(received.value)
        if (value === "" || value.length !== 6) {
            return;
        }
        switch (received.command) {
            case 'joint_temperatures':
                temperatures = value
                break;
            case 'actual_joint_voltage':
                voltages = value
                break;
            case 'actual_current':
                oldCurrent = currents
                currents = value
                break;
            default:
                console.error('Received unknown data: ' + event.data)
                break;
        }
    } catch(e) {
        console.error(e); // error in the above string (in this case, yes)!
    }
};

ws.onclose = function () {
    console.log("Closed!");
};

ws.onerror = function (err) {
    console.log(err)
};