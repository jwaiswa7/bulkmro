import callAjaxFunction from "../common/callAjaxFunction";

const show = () => {
    $('.datatable').on('click', '.comment-po-request', function (e) {
        var id = $(this).data('po-request-id')
        console.log('tttt' + title)
        var title = $(this).attr('title')
        var json = {
            url: "/overseers/po_requests/" + id + "/render_modal_form?title=" + title,
            modalId: '#addComment',
            className: '.open-modal-form',
            buttonClassName: '.confirm-cancel',
            this: $(this),
            title: title
        }
        callAjaxFunction(json)
    })
};
export default show