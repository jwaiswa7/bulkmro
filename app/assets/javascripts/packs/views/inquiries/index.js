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
        $(this).prop('disabled', true);
        let element = $(event.target);
        let dataTable = $('.datatable').dataTable();
        let data = dataTable.api().ajax.params();
        event.preventDefault();
        $.ajax({
            url: Routes.export_filtered_records_overseers_inquiries_path(),
            type: "GET",
            data: data,
            success: function () {
                $(this).prop('disabled', false);
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