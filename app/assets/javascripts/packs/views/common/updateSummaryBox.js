// to update the status in summary boxes on selected status filter

const updateSummaryBox = () => {
    let table = $('.datatable').DataTable();
    table.on('xhr', function () {
        let json = table.ajax.json() ? table.ajax.json() : {};

        $.each(json.recordsSummary, function (index, summary) {
            let statusSize = parseInt(summary['size']) || 0;
            let statusId = ".status-" + summary['status_id'];
            $(statusId).find('.status-count-' + summary['status_id']).html(new Intl.NumberFormat('en-US',{maximumFractionDigits: 0}).format(statusSize));
        });

        $.each(json.recordsTotalValue, function (index, total_value) {
            let statusId = ".status-" + index;
            $(statusId).find('.status-value-' + index).html("&#8377;" + new Intl.NumberFormat('en-US', {maximumFractionDigits: 0}).format(total_value));
        })
    });
};

export default updateSummaryBox