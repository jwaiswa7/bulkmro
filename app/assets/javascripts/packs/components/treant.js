const treant = () => {
    if (!$('.treant').exists()) return;

    let url = $('.treant').data('nodes');
    let nodeStructure = null;
    $.get(url, function (response) {
        if (response['data'] != undefined) {
            nodeStructure = response['data'];
        }

        if (nodeStructure == null) return;
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
    });
};

export default treant