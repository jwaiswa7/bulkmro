// to update the status in summary boxes on selected status filter

const updateSummaryBox = () => {
    let table = $('.datatable').DataTable();
    let currencyName =  camelize($('body').data().currencyName)
    table.on('xhr', function () {
        let json = table.ajax.json() ? table.ajax.json() : {};
        if(json.recordsMainSummary){
            $.each(json.recordsMainSummary, function (index, main_summary) {
                let mainStatusSize = parseInt(main_summary['size']) || 0;
                let mainStatusId = ".main-status-" + main_summary['status_id'];
                $(mainStatusId).find('.main-status-count-' + main_summary['status_id']).html(new Intl.NumberFormat('en-US',{maximumFractionDigits: 0}).format(mainStatusSize));
            });
        }

        $.each(json.recordsSummary, function (index, summary) {
            let statusSize = parseInt(summary['size']) || 0;
            let statusId = ".status-" + summary['status_id'];
            $(statusId).find('.status-count-' + summary['status_id']).html(new Intl.NumberFormat('en-US',{maximumFractionDigits: 0}).format(statusSize));
        });

        $.each(json.recordsTotalValue, function (index, total_value) {
            let statusId = ".status-" + index;
            $(statusId).find('.status-value-' + index).html(currencyName + new Intl.NumberFormat('en-US', {maximumFractionDigits: 0}).format(total_value));
        });


        $.each(json.recordsTotalValueWithoutTax, function (index, total_value_without_tax) {
            let statusId = ".status-" + index;
            $(statusId).find('.status-value-without-tax-' + index).html(currencyName + new Intl.NumberFormat('en-US', {maximumFractionDigits: 0}).format(total_value_without_tax));
        })

    });
};

export default updateSummaryBox
