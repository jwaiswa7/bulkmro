const globals = () => {
    Chart.defaults.global.hover.mode = 'nearest';
    // Chart.defaults.global.colors = ['#fd7e14', '#ffc107', '#dc3545', '#e83e8c'];
    Chart.defaults.global.defaultFontFamily = "'Muli', 'Helvetica Neue', 'Helvetica', 'Arial', sans-serif";
    Chart.defaults.global.defaultFontSize = 11;
};

const chartjs = () => {
    globals();
};

const barcharts = () => {
    $(".chart-bar").each(function() {
        let chart = new Chart(this, {
            type: 'bar',
            data: {
                labels: ["Red", "Blue", "Yellow", "Green", "Purple", "Orange"],
                datasets: [{
                    label: '# of Votes',
                    data: [12, 19, 3, 5, 2, 3],
                    fill: false,
                    borderWidth: 1,
                    backgroundColor: "rgba(255, 102, 0, 0.5)",
                    borderColor: "rgba(255, 102, 0, 1)"
                }]
            },
            options: {
                scales: {
                    yAxes: [{
                        ticks: {
                            beginAtZero:true
                        }
                    }]
                }
            }
        });
    });
}

export default chartjs