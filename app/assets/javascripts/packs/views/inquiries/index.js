import bindSummaryBox from '../common/bindSummaryBox'
import updateSummaryBox from '../common/updateSummaryBox'
import aggregateSummaryBox from "../salesOrders";

const index = () => {

    bindSummaryBox(".summary_box", '.status-filter');
    updateSummaryBox();
    aggregateSummaryBox();
    // To show/hide Filtered records button
    $('#export_filtered_records').hide();

    $('.datatable').on('filters:change', function () {
        $('#export_filtered_records').show();
    });

    $('#export_filtered_records').click((event) => {
        let element = $(event.target);
        let dataTable = $('.datatable').dataTable();
        let data = dataTable.api().ajax.params();
        event.preventDefault();
        $.ajax({
            url: Routes.export_filtered_records_overseers_inquiries_path(),
            type: "GET",
            data: data,
            success: function () {
                $.notify({
                    message: 'Email sent with Filtered Activities!'
                }, {
                    type: 'info'
                }, {delay: 5000});
            }
        });
    });

};

let aggregateSummaryBox = () => {
    let table = $('.datatable').DataTable();
    table.on('xhr', function () {
        let json = table.ajax.json() ? table.ajax.json() : {};
        $('.overall-status-count').html( new Intl.NumberFormat('en-IN').format(json.recordsOverallStatusCount));
        $('.overall-status-value').html("&#8377;" + new Intl.NumberFormat('en-IN').format(json.recordsOverallStatusValue));
    });
};


export default index