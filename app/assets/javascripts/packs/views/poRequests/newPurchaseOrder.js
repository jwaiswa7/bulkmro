import callAjaxFunction from '../common/callAjaxFunction';
const newPurchaseOrder = () => {
    $('form').on('change', 'select#rejection-purchase-order-dropdown', function (e) {
        if ($("#"+e.target.id+" option:selected").html() == "Others") {
            $('#purchase-order-rejection-textbox').prop("disabled", false);
            $('.po_request_comments_message').find('textarea').attr("required", true);
        } else {
            $('#purchase-order-rejection-textbox').prop("disabled", true);
            $('.po_request_comments_message').find('textarea').val('').attr("required", false);
        }
    });

    $('#rejection-purchase-order-button').click(function () {
        var id = $(this).data('po-request-id');
        var json = {
            url: "/overseers/po_requests/" + id + "/reject_purchase_order_modal",
            modalId: '#rejectPurchaseOrder',
            className: '.rejection-purchase-order',
            buttonClassName: '.confirm-reject',
            this: $(this),
            title: '',
            redirectionLink: '/overseers/po_requests'
        }
        callAjaxFunction(json)
    });
}

export default newPurchaseOrder