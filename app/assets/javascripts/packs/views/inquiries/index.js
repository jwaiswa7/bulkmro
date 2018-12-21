import bindSummaryBox from '../common/bindSummaryBox'

const index = () => {

    let table = $('.datatable').DataTable();
    table.on('xhr', function () {
        let json = table.ajax.json();
        $.each(json.recordsSummary, function (index, summary) {
            let statusSize = summary["size"];
            let statusId = "#status_" + summary["status_id"]
            $(statusId).find('h5').text(statusSize);
        })
    });

    bindSummaryBox(".summary_box", '.status-filter');
};

export default index