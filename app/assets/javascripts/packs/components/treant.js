// Makes sure that the custom file inputs have the highlighted border on file selection
const treant = (nodeStructure) => {
    if (!$('.treant').exists()) return;
    let config = {
        chart: {
            container: ".treant",
            connectors: {
                type: "step",
                style: {
                    "stroke-width": 2,
                    'stroke': '#fd7e14',
                    'arrow-end': 'block-wide-long'
                }
            },
        },
        nodeStructure: nodeStructure
    };

    new Treant(config, function() {}, $);
};

export default treant