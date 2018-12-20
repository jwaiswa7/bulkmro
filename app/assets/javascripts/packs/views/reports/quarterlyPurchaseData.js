const quarterlyPurchaseData = () => {

    Object.values(Chart.instances).forEach(updateChartOptions)

    /*$('canvas.chart').each(function (index, object) {
        console.log(object);
        var myChart = new Chart(object, barChartOptions);
        myChart.options = barChartOptions;
        myChart.update();

    });*/

};


let updateChartOptions = function (chartObject) {
    if (chartObject.canvas.id == 'quarterly_purchase_data') {
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
                }, {
                    id: 'revenue',
                    type: 'linear',
                    position: 'left',
                    ticks: {
                        display: true,
                        userCallback: function (value) {
                            value = value.toString();
                            return '₹' + value.toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
                        }
                    },
                    scaleLabel: {
                        display: true,
                        labelString: 'Revenue'
                    }
                }]
            }
        };
        chartObject.options = barChartOptions;
        chartObject.update();
    }
}


export default quarterlyPurchaseData