import updateSummaryBox from "../common/updateSummaryBox";
import callAjaxFunction from '../common/callAjaxFunction';
const index = () => {
    updateSummaryBox()

    $('.datatable').on('click','.cancel-invoice',function () {
        if( confirm('Do you want to cancel invoice request') ) {
            var id = $(this).data('invoice-request-id')
            var status = $('.open-modal-form').data('status')
            var title = "Cancel"
            var json = {
                url: "/overseers/invoice_requests/" + id + "/render_modal_form?status=" +status,
                modalId: '#cancelInvoice',
                className: '.open-modal-form',
                buttonClassName: '.confirm-cancel',
                this: $(this),
                title: title,
            }
            callAjaxFunction(json)
        }
    })

    $('.datatable').on('click', '.comment-invoice-request', function (e) {
        var id = $(this).data('invoice-request-id')
        var title = "Comment"
        var json = {
            url: "/overseers/invoice_requests/" + id + "/render_modal_form?title=" +title,
            modalId: '#addComment',
            className: '.open-modal-form',
            buttonClassName: '.confirm-cancel',
            this: $(this),
            title: title,
        }
        callAjaxFunction(json)

    })

};

export default index