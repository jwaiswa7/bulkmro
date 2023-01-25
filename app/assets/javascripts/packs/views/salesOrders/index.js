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
    $('.sprint-loader').hide();
    $('.datatable').on('init.dt', function (event) {
        var date = window.hasher.getParam('Order Date')
        if (date != '' && $('.bmro-date-bag').val() == ''){
            $('.bmro-date-bag').val(date).trigger('change')
        }
    });
};

let salesOrderCancel = () => {
    $('.cancel-sales-order-button').click(function () {
        let url = $(this).data('url');
        $('.confirm-sales-order-cancel').prop('disabled', true);
        $.ajax({
            url: url,
            success: function (data) {
                $('.sales-order-cancel').empty();
                $('.sales-order-cancel').append(data);
                $('#cancelSalesOrder').modal('show');
                $('.confirm-sales-order-cancel').prop('disabled', true);
                $('.sprint-loader').hide();

                $('.cancellation-msg').on('keyup', function (event) {
                    if($(this).val() === '' || $(this).val() === 'undefined') {
                        $('.confirm-sales-order-cancel').prop('disabled', true);
                    }
                    else {
                        $('.confirm-sales-order-cancel').prop('disabled', false);
                    }
                });
                orderCancelledSubmit();
            }
        });
    });
};

let salesOrderCancelAutoEmail = () => {
    $('.cancel-sales-order-isp').click(function () {
        let url = $(this).data('url');

        // if url.split('/') ==
        $.ajax({
            url: url,
            success: function (data) {
                $('.sales-order-cancel').empty();
                $('.sales-order-cancel').append(data);
                $('#cancelSalesOrder').modal('show');
                $('.sprint-loader').hide();
                let data_url = $('.cancel-button').data('url');
                let action = data_url.split('/').pop();
                $('.cancel-button').prop('disabled', true);

                $('.cancellation-msg').on('change', function (event) {
                    if($(this).val() === '' || $(this).val() === 'undefined') {
                        $('.cancel-button').prop('disabled', true);
                    }
                    else {
                        $('.cancel-button').prop('disabled', false);
                    }
                });
                if (action == 'isp_order_cancellation') {
                    orderCancelAccount('.confirm-sales-order-cancel');
                } else {
                    orderCancelAccount('.auto-email-so-cancel');
                }
            }
        });
    });

};

let orderCancelledSubmit = () => {
    $("#cancelSalesOrder").on('click', '.confirm-sales-order-cancel', function (event) {
        $(this).attr('disabled', true);
        $('.sprint-loader').show();
        let formSelector = "#" + $(this).closest('form').attr('id'),
            datastring = $(formSelector).serialize();

        $.ajax({
            type: "PATCH",
            url: $(formSelector).attr('action'),
            data: datastring,
            dataType: "json",
            success: function success(data) {
                $('#cancelSalesOrder').modal('hide');
                $.notify({
                    message: data.responseJSON.notice
                }, {
                    type: 'warning'
                }, {delay: 5000});
                window.location.reload();
            },
            error: function error(_error) {
                if (_error.responseJSON && _error.responseJSON.error)
                    $(formSelector).find('.error').empty().html("<div class='p-1'>" + _error.responseJSON.error + "</div>");
            }
        });
        event.preventDefault();
    });
};

let orderCancelAccount = (class_name) => {
    $("#cancelSalesOrder").on('click', class_name, function (event) {
        if (confirm('Are you sure you want to cancel SO?')) {
            $(this).attr('disabled', true);
            $('.sprint-loader').show();
            let formSelector = "#" + $(this).closest('form').attr('id');
            let form = $(formSelector)[0];
            let formData = new FormData(form);
            let url = $(this).data('url');
            $(formSelector).attr('method', '');
            $.ajax({
                url: url,
                type: "POST",
                data: formData,
                dataType: "json",
                processData: false,
                contentType: false,
                success: function success(data) {
                    $('#cancelSalesOrder').modal('hide');
                    $.notify({
                        message: data.notice
                    }, {
                        type: 'warning'
                    }, {delay: 5000});
                    window.location.reload();
                },
                error: function error(_error) {
                    if (_error.responseJSON && _error.responseJSON.error)
                        $(formSelector).find('.error').empty().html("<div class='p-1'>" + _error.responseJSON.error + "</div>");
                }
            });
        } else {
            $('#cancelSalesOrder').modal('hide');
        }
        event.preventDefault();
    })
};

let aggregateSummaryBox = () => {
    let table = $('.datatable').DataTable();
    let currencyName =  camelize($('body').data().currencyName)
    table.on('xhr', function () {
        let json = table.ajax.json() ? table.ajax.json() : {};
        $('.overall-status-count').html( new Intl.NumberFormat('en-IN').format(json.recordsOverallStatusCount));
        $('.overall-status-value').html(currencyName + new Intl.NumberFormat('en-IN').format(json.recordsOverallStatusValue));
    });

    $('.order-filter').on('click', function (e) {
        $("#export-filters").find(".modal-content").html();
        $("#export-filters").modal();
    });
};

export default index
