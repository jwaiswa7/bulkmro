import bindSummaryBox from '../common/bindSummaryBox'
import updateSummaryBox from '../common/updateSummaryBox'

const index = () => {

    bindSummaryBox(".summary_box", '.status-filter');
    updateSummaryBox();

    // To show/hide Filtered records button
    $('#export_filtered_records').hide();

    $('.datatable').on('filters:change', function() {
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

            }
        });
    });
};

export default index