import bindSummaryBox from '../common/bindSummaryBox'
import updateSummaryBox from "../common/updateSummaryBox";
import exportFilteredRecords from "../common/exportFilteredRecords";
import commanComment from "../common/commanComment";
import removeHrefExport from '../common/removeHrefExport';

const index = () => {
    bindSummaryBox(".summary_box", '.status-filter')
    updateSummaryBox();
    aggregateSummaryBox();
    $('#export_filtered_records').hide();
    let controller = camelize($('body').data().controller);
    exportFilteredRecords(Routes.export_filtered_records_overseers_sales_orders_path(), 'Email sent with Filtered ' + controller.titleize() + '!')
    salesOrderCancel();
    salesOrderCancelAutoEmail();

    commanComment('sales-order','sales_orders');
    removeHrefExport();
};

let salesOrderCancel = () => {
    $('.cancel-sales-order-button').click(function () {
        let inqId = $(this).data('inquiry-id');
        let orderId = $(this).data('order-id');
        let url = $(this).data('url');

        $.ajax({
            url: url,
            success: function (data) {
                $('.sales-order-cancel').empty();
                $('.sales-order-cancel').append(data);
                $('#cancelSalesOrder').modal('show');
                orderCancelledSubmit()
            }
        });
    });

};

let salesOrderCancelAutoEmail = () => {
    $('.cancel-sales-order-isp').click(function () {
        let inqId = $(this).data('inquiry-id');
        let orderId = $(this).data('order-id');
        let url = $(this).data('url');

        $.ajax({
            url: url,
            success: function (data) {
                $('.sales-order-cancel').empty();
                $('.sales-order-cancel').append(data);
                $('#cancelSalesOrder').modal('show');
                orderCancelAutoEmailSubmit();
            }
        });
    });

};

let orderCancelledSubmit = () => {
    $("#cancelSalesOrder").on('click', '.confirm-sales-order-cancel', function (event) {
        let formSelector = "#" + $(this).closest('form').attr('id'),
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
    });
};

let orderCancelAutoEmailSubmit = () => {
    $("#cancelSalesOrder").on('click', '.auto-email-so-cancel', function (event) {
        $(this).attr('disabled', true);
        let formSelector = "#" + $(this).closest('form').attr('id');
        let url = $(this).data('url');
        $(formSelector).attr('method', '');
        $.ajax({
            url: url,
            type: "POST",
            data: $(this).closest('form').serialize(),
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