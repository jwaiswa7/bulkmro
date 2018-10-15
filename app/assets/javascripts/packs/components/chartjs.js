const colors = ['#fd7e14', '#ffc107', '#dc3545', '#e83e8c'];

const globals = () => {
    Chart.defaults.global.hover.mode = 'nearest';
    Chart.defaults.global.defaultFontFamily = "'Muli', 'Helvetica Neue', 'Helvetica', 'Arial', sans-serif";
    Chart.defaults.global.defaultFontSize = 11;
    Chart.helpers.merge(Chart.defaults.global, {
        aspectRatio: 4/3,
        layout: {
            padding: {
                top: 42,
                right: 16,
                bottom: 32,
                left: 8
            }
        },

        elements: {
            line: {
                fill: false
            },
            point: {
                hoverRadius: 7,
                radius: 5
            }
        },

        plugins: {
            title: false
        }
    });
};

const chartjs = () => {
    globals();
    barcharts();
};

const barcharts = () => {
    $(".chart-bar").each(function() {
        let chartAxis = $(this).data('chart-axis');
        let chartLabels = $(this).data('chart-labels');
        let chartData = $(this).data('chart-data');
        let datasets = [];

        // Prepare datasets
        chartData.forEach(function(val, index) {
            datasets[index] = {
                label: chartLabels[index],
                data: val,
                fill: false,
                borderWidth: 1,
                backgroundColor: colors[index] + '80', // 50% hex opacity
                borderColor: colors[index] + 'ff', // 100% hex opacity
                datalabels: {
                    align: 'end',
                    anchor: 'start'
                }
            }
        });

        let chart = new Chart($(this)[0], {
            type: 'bar',
            data: {
                labels: chartAxis,
                datasets: datasets
            },
            options: {
                scales: {
                    yAxes: [{
                        ticks: {
                            beginAtZero:true
                        },
                    }]
                },

                plugins: {
                    datalabels: {
                        color: 'black',
                        display: function(context) {
                            console.log('!!!');
                            return context.dataset.data[context.dataIndex] > 15;
                        },
                        font: {
                            weight: 'bold'
                        },
                        formatter: Math.round
                    }
                },
            }
        });
    });
}

export default chartjs