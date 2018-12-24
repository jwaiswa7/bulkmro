const monthlyPurchaseData = () => {

    Object.values(Chart.instances).forEach(updateChartOptions)

    /*$('canvas.chart').each(function (index, object) {
        console.log(object);
        var myChart = new Chart(object, barChartOptions);
        myChart.options = barChartOptions;
        myChart.update();

    });*/

};


let updateChartOptions = function (chartObject) {
    if (chartObject.canvas.id == 'monthly_purchase_data') {
        var barChartOptions = {
            tooltips: {
                mode: 'label',
                callbacks: {
                    label: function (tooltipItem) {
                        return tooltipItem.yLabel.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1,");
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
                            // return '₹' + value.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
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
};


export default monthlyPurchaseData