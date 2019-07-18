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
    salesOrderCancel()
};

let salesOrderCancel = () => {
    $('.cancel-sales-order-button').click(function () {
        var inq_id = $('.sales-order-cancel')[0].dataset.inquiryId
        var order_id = $('.sales-order-cancel')[0].dataset.orderId
        $.ajax({
            url: "/overseers/inquiries/"+inq_id+"/sales_orders/"+order_id+"/order_cancellation_modal",
            success: function (data) {
                $('.sales-order-cancel').empty()
                $('.sales-order-cancel').append(data)
                $('#cancelSalesOrder').modal('show')
                orderCancelledSubmit()
            }
        });
    });
}

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
        })
        event.preventDefault();
    })
}

let aggregateSummaryBox = () => {
    let table = $('.datatable').DataTable();
    table.on('xhr', function () {
        let json = table.ajax.json() ? table.ajax.json() : {};
        $('.overall-status-count').html( new Intl.NumberFormat('en-IN').format(json.recordsOverallStatusCount));
        $('.overall-status-value').html("&#8377;" + new Intl.NumberFormat('en-IN').format(json.recordsOverallStatusValue));
    });
}

export default index