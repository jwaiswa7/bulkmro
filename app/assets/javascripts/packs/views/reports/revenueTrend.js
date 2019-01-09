const revenueTrend = () => {
    Object.values(Chart.instances).forEach(updateChartOptions)
};

let updateChartOptions = function (chartObject) {
    if (chartObject.canvas.id == 'revenue_trend') {
        var barChartOptions = {
            tooltips: {
                mode: 'label',
                callbacks: {
                    label: function (tooltipItem) {
                        return '₹ Lacs' + '-' + (tooltipItem.yLabel/100000).toFixed(2);
                    },
                }
            },

            scales: {
                yAxes: [
                    {
                        id: 'revenue',
                        type: 'linear',
                        position: 'left',
                        ticks: {
                            display: true,
                            userCallback: function (value) {
                                value = value.toString();
                                return '₹' + (value / 100000) + ' Lacs';
                            }
                        },
                        scaleLabel: {
                            display: true,
                            labelString: '₹ Lacs'
                        },
                        gridLines: {
                            display: true
                        }
                    }
                ]
            }
        };
        chartObject.options = barChartOptions;
        chartObject.update();
    }
};

export default revenueTrend