const treant = () => {
    if (!$('.treant').exists()) return;

    let url = $('.treant').data('nodes');
    let nodeStructure = null;

    let spinner = '<div class="text-center spinner"><i class=" fal fa-spinner-third fa-spin fa-3x fa-fw"></i></div>';
    spinner = $(spinner).insertAfter($('.treant'));

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
        spinner.remove();
    });
};

export default treant