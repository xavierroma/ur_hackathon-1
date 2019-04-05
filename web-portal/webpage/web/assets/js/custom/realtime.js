var ws = new WebSocket("ws://192.168.1.40:30101/");

var temperatures;
var oldTemperatures;
var actual = 0;

ws.onopen = function () {
    console.log("opened")
};

ws.onmessage = function (event) {
    try {
        oldTemperatures = temperatures
        temperatures = JSON.parse(event.data)
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

setInterval(function updateTemperature() {
    ws.send('joint_temperatures')
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
        interval = 600

        max = 50
        min = 30

        function getRandomData(i, data) {


            data = data.slice(1);

            while (data.length < maximum) {
                var previous = data.length ? data[data.length - 1] : 0;
                var y = previous + Math.random() - 0.5;
                if ((temperatures === undefined) || (temperatures[i] === undefined)) {
                    if ((oldTemperatures === undefined) || (oldTemperatures[i] === undefined)) {
                        data.push(y < min ? min : y > max ? max : y);
                    } else {
                        data.push(oldTemperatures[i]);
                    }
                } else {
                    data.push(temperatures[i]);
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
