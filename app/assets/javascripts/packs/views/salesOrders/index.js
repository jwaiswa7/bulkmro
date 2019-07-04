import bindSummaryBox from '../common/bindSummaryBox'
import updateSummaryBox from "../common/updateSummaryBox";
import exportFilteredRecords from "../common/exportFilteredRecords";

const index = () => {
    bindSummaryBox(".summary_box", '.status-filter')
    updateSummaryBox()
    aggregateSummaryBox()
    $('#export_filtered_records').hide()
    let controller = camelize($('body').data().controller);
    exportFilteredRecords(Routes.export_filtered_records_overseers_sales_orders_path(), 'Email sent with Filtered ' + controller.titleize() + '!')
};

let aggregateSummaryBox = () => {
    let table = $('.datatable').DataTable();
    table.on('xhr', function () {
        let json = table.ajax.json() ? table.ajax.json() : {};
        $('.overall-status-count').html(new Intl.NumberFormat('en-IN').format(json.recordsOverallStatusCount));
        $('.overall-status-value').html("&#8377;" + new Intl.NumberFormat('en-IN').format(json.recordsOverallStatusValue));
    });


    $('.message-in-order').on('click', function (e) {
        // alert('Welcome')
        // $("#modal-window").find(".modal-content").html("new.html.erb");
        // $("#modal-window").modal();

        $("#modal-window").find(".modal-content").html();
        $("#modal-window").modal();
    });

}


export default index