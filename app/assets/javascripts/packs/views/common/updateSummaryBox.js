// to update the status in summary boxes on selected status filter

const updateSummaryBox = () => {
    let table = $('.datatable').DataTable();
    table.on('xhr', function () {
        let json = table.ajax.json();
        $.each(json.recordsSummary, function (index, summary) {
            let statusSize = summary["size"];
            let statusId = "#status_" + summary["status_id"]
            $(statusId).find('h5').text(statusSize);
        })
    });
};

export default updateSummaryBox