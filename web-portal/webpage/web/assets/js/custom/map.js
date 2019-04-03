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

$(window).onload(function (e) {
    sparklineLogin();
})

$(document).onload(function (e) {
    sparklineLogin();
})

clearTimeout(sparkResize);
sparkResize = setTimeout(sparklineLogin, 100);