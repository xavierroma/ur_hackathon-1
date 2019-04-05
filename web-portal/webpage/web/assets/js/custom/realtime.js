setInterval(function updatePanelTemp() {
    ws.send('joint_temperatures')
    for (let i = 0; i < 6; i++) {
        $("#temperature" + i).text(temperatures[i])
    }
}, 1000);

setInterval(function updatePanelCurrent() {
    ws.send('actual_current')
    for (let i = 0; i < 6; i++) {
        var string = $("#current" + i).text((Math.abs(currents[i])).toString().slice(0,6))
    }
}, 1000);

setInterval(function updatePanelVoltage() {
    ws.send('actual_joint_voltage')
    for (let i = 0; i < 6; i++) {
        var string = $("#voltage" + i).text(voltages[i].toString().slice(0,6))
    }
}, 1000);

$(document).ready(function() {
    var sparklineLogin = function() {
        $("#sparkline1dash").sparkline([0, 23, 43, 35, 44, 45, 56, 37, 40, 45, 56, 7, 10], {
            type: 'line',
            width: '100%',
            height: '70',
            lineColor: '#fff',
            fillColor: 'transparent',
            spotColor: '#fff'
        });
        $('#sparkline2dash').sparkline([10, 12, 9, 6, 10, 9, 11, 9, 10, 12, 9, 11, 9, 10, 12], {
            type: 'bar',
            height: '70',
            barWidth: '5',
            resize: true,
            barSpacing: '10',
            barColor: '#fff'
        });
        $("#sparkline3dash").sparkline([130, 123, 120, 130, 140, 210, 152, 143, 128, 122, 123, 135, 128], {
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
        $('#sparkline4dash').sparkline([10, 12, 9, 6, 10, 9, 11, 9, 10, 12, 9, 11, 9, 10, 12], {
            type: 'bar',
            height: '70',
            barWidth: '5',
            resize: true,
            barSpacing: '10',
            barColor: '#fff'
        });

    }
    var sparkResize;

    $(window).resize(function(e) {
        clearTimeout(sparkResize);
        sparkResize = setTimeout(sparklineLogin, 100);
    });
    sparklineLogin();

});

$(function () {

    var plots = []
    var data = [];
    var series = [];

    for (let i = 0; i < 12; i++) {

        var container = $("#flot-line-chart-moving" + i);

        // Determine how many data points to keep based on the placeholder's initial size;
        // this gives us a nice high-res plot while avoiding more than one point per pixel.

        var maximum = container.outerWidth() / 2 || 300;

        //
        data.push([])

        var max, min, interval;
        interval = 1000

        max = 2
        min = 0

        function getRandomData(i, data) {


            data = data.slice(1);

            while (data.length < maximum) {
                var previous = data.length ? data[data.length - 1] : 0;
                var y = previous + Math.random() - 0.5;
                if ((currents === undefined)) {
                    if ((oldCurrent === undefined) || (oldCurrent[i] === undefined)) {
                        data.push(y < min ? min : y > max ? max : y);
                    } else {
                        data.push(Math.abs(oldCurrent[i]))
                    }
                } else {
                    data.push(Math.abs(currents[i]));
                }
            }

            // zip the generated y values with the x values

            var res = [];
            for (var i = 0; i < data.length; ++i) {
                res.push([i, data[i]])
            }

            return res;
        }

        //

        series.push([{
            data: getRandomData(i, data[i]),
            lines: {
                fill: true
            }
        }]);
        plots.push($.plot(container, series[i], {
            colors: ["#00b5c2"],
            grid: {
                borderWidth: 0,
                minBorderMargin: 20,
                labelMargin: 10,
                backgroundColor: {
                    colors: ["#fff", "#fff"]
                },
                margin: {
                    top: 8,
                    bottom: 20,
                    left: 20
                },

                markings: function (axes) {
                    var markings = [];
                    var xaxis = axes.xaxis;
                    for (var x = Math.floor(xaxis.min); x < xaxis.max; x += xaxis.tickSize * 1) {
                        markings.push({
                            xaxis: {
                                from: x,
                                to: x + xaxis.tickSize
                            },
                            color: "#fff"
                        });
                    }
                    return markings;
                }
            },
            xaxis: {
                tickFormatter: function () {
                    return "";
                }
            },
            yaxis: {
                min: min,
                max: max
            },
            legend: {
                show: true
            }
        }));
        // Update the random dataset at 25FPS for a smoothly-animating chart

        setInterval(function updateRandom() {
            series[i][0].data = getRandomData(i, data[i]);
            plots[i].setData(series[i]);
            plots[i].draw();
        }, interval);

    }

});
