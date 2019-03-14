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
        element.prop('disabled', true);
        let dataTable = $('.datatable').dataTable();
        let data = dataTable.api().ajax.params();
        event.preventDefault();
        $.ajax({
            url: Routes.export_filtered_records_overseers_inquiries_path(),
            type: "GET",
            data: data,
            error: function () {
                element.prop('disabled', false);
                $.notify({
                    message: 'Email is not delivered. Please export all activities'
                }, {
                    type: 'danger'
                }, {delay: 1000});
            },
            success: function () {
                element.prop('disabled', false);
                $.notify({
                    message: 'Email sent with Filtered Activities!'
                }, {
                    type: 'info'
                }, {delay: 5000});
            }
        });
    });

};




export default index