const monthlyPurchaseData = () => {
    Object.values(Chart.instances).forEach(updateChartOptions)
};

let updateChartOptions = function (chartObject) {
    if (chartObject.canvas.id == 'monthly_purchase_data') {
        var barChartOptions = {
            tooltips: {
                mode: 'label',
                callbacks: {
                    label: function (tooltipItem, data) {
                        var dataset = data.datasets[tooltipItem.datasetIndex];
                        if(dataset.label == 'Products'){
                            var tooltip = dataset.label + ' - ' + dataset.data[tooltipItem.index];
                        }
                        else if(dataset.label == '₹ Lacs'){
                            tooltip = dataset.label + ' - ' + (dataset.data[tooltipItem.index]/100000).toFixed(2);
                        }
                        return tooltip;
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
};

export default monthlyPurchaseData