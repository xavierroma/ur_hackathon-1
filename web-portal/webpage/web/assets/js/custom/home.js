
setInterval(function updateMontaje() {
    var string = $("#montaje").text()
    var x  = Number(string.substring(0, string.length - 1))
    var random = Math.random() * 10;
    if (random > 5) {
        x = x + 1;
    } else {
        x = x - 1;
    }
    $("#montaje").text(x + "s")
}, 5000);



setInterval(function updateCiclos() {
    var string = $("#ciclos").text()
    var x  = Number(string)
    x = x + 1;
    $("#ciclos").text(x)
}, 10000);
