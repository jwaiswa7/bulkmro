const colors = ['#fd7e14', '#ffc107', '#dc3545', '#e83e8c'];

const globals = () => {
    Chart.defaults.global.hover.mode = 'nearest';
    Chart.defaults.global.defaultFontFamily = "'Muli', 'Helvetica Neue', 'Helvetica', 'Arial', sans-serif";
    Chart.defaults.global.defaultFontSize = 11;
    Chart.defaults.global.defaultFontStyle = "bold";
    Chart.defaults.scale.gridLines.display = false;
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
        //
        // plugins: {
        //     title: false
        // }
    });
};

const chartjs = () => {
    globals();
};

export default chartjs