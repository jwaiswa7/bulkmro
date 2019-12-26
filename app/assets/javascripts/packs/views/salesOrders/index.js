import bindSummaryBox from '../common/bindSummaryBox'
import updateSummaryBox from "../common/updateSummaryBox";
import exportFilteredRecords from "../common/exportFilteredRecords";
import commanComment from "../common/commanComment";
import removeHrefExport from '../common/removeHrefExport';
import openModal from "../common/openModal";

const index = () => {
    bindSummaryBox(".summary_box", '.status-filter')
    updateSummaryBox();
    aggregateSummaryBox();
    $('#export_filtered_records').hide();
    let controller = camelize($('body').data().controller);
    exportFilteredRecords(Routes.export_filtered_records_overseers_sales_orders_path(), 'Email sent with Filtered ' + controller.titleize() + '!')
    salesOrderCancel();

    commanComment('sales-order','sales_orders');
    removeHrefExport();
};

let salesOrderCancel = () => {
    $('.cancel-sales-order-button').click(function () {
        var inqId = $(this).attr('data-inquiry-id');
        var orderId = $(this).attr('data-order-id');
        $.ajax({
            url: "/overseers/inquiries/"+inqId+"/sales_orders/"+orderId+"/order_cancellation_modal",
            success: function (data) {
                $('.sales-order-cancel').empty();
                $('.sales-order-cancel').append(data);
                $('#cancelSalesOrder').modal('show');
                orderCancelledSubmit()
            }
        });
    });
};

let orderCancelledSubmit = () => {
    $("#cancelSalesOrder").on('click', '.confirm-sales-order-cancel', function (event) {
        var formSelector = "#" + $(this).closest('form').attr('id'),
        datastring = $(formSelector).serialize();

        $.ajax({
            type: "PATCH",
            url: $(formSelector).attr('action'),
            data: datastring,
            dataType: "json",
            success: function success(data) {
                $('#cancelSalesOrder').modal('hide');
                window.location.reload()
            },
            error: function error(_error) {
                if (_error.responseJSON && _error.responseJSON.error)
                    $(formSelector).find('.error').empty().html("<div class='p-1'>" + _error.responseJSON.error + "</div>");
            }
        });
        event.preventDefault();
    })
};

let aggregateSummaryBox = () => {
    let table = $('.datatable').DataTable();
    table.on('xhr', function () {
        let json = table.ajax.json() ? table.ajax.json() : {};
        $('.overall-status-count').html( new Intl.NumberFormat('en-IN').format(json.recordsOverallStatusCount));
        $('.overall-status-value').html("&#8377;" + new Intl.NumberFormat('en-IN').format(json.recordsOverallStatusValue));
    });

    $('.order-filter').on('click', function (e) {
        $("#export-filters").find(".modal-content").html();
        $("#export-filters").modal();
    });
};

export default index