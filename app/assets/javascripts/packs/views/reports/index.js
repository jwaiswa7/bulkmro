const index = () => {
    Object.values(Chart.instances).forEach(updateChartOptions)
};

let updateChartOptions = function (chartObject) {
    if (chartObject.canvas.id == 'monthly_purchase_data') {
        var barChartOptions = {
            tooltips: {
                mode: 'label',
                callbacks: {
                    label: function (tooltipItem) {
                        return Math.round(tooltipItem.yLabel).toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1,");
                    },
                }
            },
            scales: {
                yAxes: [{
                    id: 'products_count',
                    type: 'linear',
                    position: 'right',
                    ticks: {
                        display: false
                    }
                }, {
                    id: 'revenue',
                    type: 'linear',
                    position: 'left',
                    ticks: {
                        display: true,
                        label: {
                            fontStyle: 500
                        },
                        userCallback: function (value) {
                            value = value.toString();
                            return '₹' + (value/100000) + ' Lacs';
                        }
                    },
                    scaleLabel: {
                        display: true,
                        labelString: '₹ Lacs'
                    },
                    gridLines: {
                        display: true
                    }
                }]
            }
        };
        chartObject.options = barChartOptions;
        chartObject.update();
    }
    else if (chartObject.canvas.id == 'revenue_trend') {
        var barChartOptions = {
            tooltips: {
                mode: 'label',
                callbacks: {
                    label: function (tooltipItem) {
                        return Math.round(tooltipItem.yLabel).toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1,");
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

export default index

// chartObject.destroy();
// return '₹' + value.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");