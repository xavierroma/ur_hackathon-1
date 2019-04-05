
setInterval(function updateMontaje() {
    var string = $("#montajep").text()
    console.log(string)
    var x  = Number(string.substring(0, string.length - 1))
    console.log(x)
    var random = Math.random() * 10;
    if (random > 5) {
        x = x + 1;
    } else {
        x = x - 1;
    }
    $("#montajep").text(x + "s")
}, 5000);


setInterval(function updateCiclos() {
    var string = $("#ciclos").text()
    var x  = Number(string)
    x = x + 1;
    $("#ciclos").text(x)
}, 10000);
