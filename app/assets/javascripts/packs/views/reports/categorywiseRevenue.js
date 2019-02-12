const categorywiseRevenue = () => {
    Object.values(Chart.instances).forEach(updateChartOptions)
};

let updateChartOptions = function (chartObject) {
    if (chartObject.canvas.id == 'categorywise_revenue') {
        var doughnutChartOptions = {
            tooltips: {
                callbacks: {
                    label: function(tooltipItem, data) {
                        var dataset = data.datasets[tooltipItem.datasetIndex];
                        return data.labels[tooltipItem.index] + '-' + dataset.data[tooltipItem.index].toFixed(2) + "%";
                    }
                }
            }
        };
        chartObject.options = doughnutChartOptions;
        chartObject.update();
    }
};

export default categorywiseRevenue