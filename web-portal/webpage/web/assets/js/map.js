
var sparklineLogin = function() {
    $("#sparkline1dash").sparkline([0, 23, 43, 35, 44, 45, 56, 37, 40, 45, 56, 7, 10], {
        type: 'line',
        width: '100%',
        height: '70',
        lineColor: '#fff',
        fillColor: 'transparent',
        spotColor: '#fff',
        minSpotColor: undefined,
        maxSpotColor: undefined,
        highlightSpotColor: undefined,
        highlightLineColor: undefined
    });
    $('#sparkline2dash').sparkline([10, 12, 9, 6, 10, 9, 11, 9, 10, 12, 9, 11, 9, 10, 12,], {
        type: 'bar',
        height: '70',
        barWidth: '5',
        resize: true,
        barSpacing: '10',
        barColor: '#fff'
    });
    $("#sparkline3dash").sparkline([0, 23, 43, 35, 44, 45, 56, 37, 40, 45, 56, 7, 10], {
        type: 'line',
        width: '100%',
        height: '70',
        lineColor: '#fff',
        fillColor: 'transparent',
        spotColor: '#fff',
        minSpotColor: undefined,
        maxSpotColor: undefined,
        highlightSpotColor: undefined,
        highlightLineColor: undefined
    });
    $('#sparkline4dash').sparkline([10, 12, 9, 6, 10, 9, 11, 9, 10, 12, 9, 11, 9, 10, 12,], {
        type: 'bar',
        height: '70',
        barWidth: '5',
        resize: true,
        barSpacing: '10',
        barColor: '#fff'
    });
    $('#sales1').sparkline([20, 40, 30], {
        type: 'pie',
        height: '100',
        resize: true,
        sliceColors: ['#808f8f', '#fecd36', '#f1f2f7']
    });
    $('#sales2').sparkline([6, 10, 9, 11, 9, 10, 12], {
        type: 'bar',
        height: '154',
        barWidth: '4',
        resize: true,
        barSpacing: '10',
        barColor: '#25a6f7'
    });
    $("#sparkline8").sparkline([2,4,4,6,8,5,6,4,8,6,6,2 ], {
        type: 'line',
        width: '100%',
        height: '50',
        lineColor: '#99d683',
        fillColor: '#99d683',
        maxSpotColor: '#99d683',
        highlightLineColor: 'rgba(0, 0, 0, 0.2)',
        highlightSpotColor: '#99d683'
    });
    $("#sparkline9").sparkline([0,2,8,6,8,5,6,4,8,6,6,2 ], {
        type: 'line',
        width: '100%',
        height: '50',
        lineColor: '#13dafe',
        fillColor: '#13dafe',
        minSpotColor:'#13dafe',
        maxSpotColor: '#13dafe',
        highlightLineColor: 'rgba(0, 0, 0, 0.2)',
        highlightSpotColor: '#13dafe'
    });
    $("#sparkline10").sparkline([2,4,4,6,8,5,6,4,8,6,6,2], {
        type: 'line',
        width: '100%',
        height: '50',
        lineColor: '#ffdb4a',
        fillColor: '#ffdb4a',
        maxSpotColor: '#ffdb4a',
        highlightLineColor: 'rgba(0, 0, 0, 0.2)',
        highlightSpotColor: '#ffdb4a'
    });

}
var sparkResize;

$(window).resize(function(e) {
    clearTimeout(sparkResize);
    sparkResize = setTimeout(sparklineLogin, 100);
});
sparklineLogin();