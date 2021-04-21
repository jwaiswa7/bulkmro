import bindSummaryBox from '../common/bindSummaryBox'
import updateSummaryBox from "../common/updateSummaryBox";
import callAjaxFunction from '../common/callAjaxFunction';
import commanComment from "../common/commanComment";
const index = () => {
    bindSummaryBox(".summary_box", '.status-filter')
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

    commanComment('invoice-request','invoice_requests');
};

export default index