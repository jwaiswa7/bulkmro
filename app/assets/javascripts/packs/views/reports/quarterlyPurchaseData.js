const quarterlyPurchaseData = () => {
    var barChartOptions = {
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
    window.chart.chart.options = barChartOptions;
    window.chart.chart.update();
};

export default quarterlyPurchaseData