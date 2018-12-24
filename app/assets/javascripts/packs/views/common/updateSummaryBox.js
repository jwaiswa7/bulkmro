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
    });
};

export default updateSummaryBox