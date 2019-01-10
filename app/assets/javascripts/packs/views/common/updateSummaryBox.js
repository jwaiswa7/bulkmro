// to update the status in summary boxes on selected status filter

const updateSummaryBox = () => {
    let table = $('.datatable').DataTable();
    table.on('xhr', function () {
        let json = table.ajax.json();
        $.each(json.recordsSummary, function (index, summary) {
            let statusSize = summary["size"];
            let statusId = ".status-" + summary["status_id"]
            $(statusId).find('.status-count-'+summary["status_id"]).text(statusSize);
        })
        $.each(json.recordsTotalValue, function (index, total_value) {
            let statusId = ".status-" + index
            $(statusId).find('.status-value-'+index).text("INR "+total_value);
        })
    });
};

export default updateSummaryBox