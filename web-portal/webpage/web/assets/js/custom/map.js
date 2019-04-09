var sparklineLogin = function() {
    for (let i = 0; i < 20; i += 2) {
        $("#sparkline" + i + "map").sparkline([0, 23, 43, 35, 44, 45, 56, 37, 40, 45, 56, 7, 10, 56, 37, 40, 45, 56, 7, 10], {
            type: 'line',
            height: '70px',
            width: '100%',
            lineColor: '#fff',
            fillColor: 'transparent',
            spotColor: '#fff'
        });
        $("#sparkline" + (i + 1) + "map").sparkline([10, 12, 9, 6, 10, 9, 11, 9, 10, 12, 9, 11, 9, 10, 12], {
            type: 'bar',
            height: '70',
            barWidth: '5',
            resize: true,
            barSpacing: '10',
            barColor: '#fff'
        });
    }
}
var sparkResize;

$(window).resize(function(e) {
    clearTimeout(sparkResize);
    sparkResize = setTimeout(sparklineLogin, 100);
});

sparklineLogin();

clearTimeout(sparkResize);
sparkResize = setTimeout(sparklineLogin, 100);

var direction = 1;
var opacity = 0.0;

var heartbeat = function() {

    if (direction) {
        opacity = opacity + 0.1;
    }

    if (!direction) {
        opacity = opacity - 0.1;
    }

    if (opacity >= 1.0 || opacity < 0.0) {
        direction = !direction;
    }

    for (let i = 1; i < 7; i++) {
        $("#robot" + i).css('opacity', opacity);
        console.log("robot" + i + " has " + opacity + ", " + direction);
    }
}

var myVar;

$(document).ready(function(){
    $("img").load(function(){
        setTimeout(f, 2000);
    });
});

function f() {
    console.log("loaded")
    clearInterval(myVar);
    myVar = setInterval(heartbeat, 100);
}

/*
window.onload = function (e) {
    clearInterval(myVar);
    myVar = setInterval(heartbeat, 100);
})
*/