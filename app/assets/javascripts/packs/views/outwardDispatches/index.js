import callAjaxFunction from "../common/callAjaxFunction";

const index = () => {

    $('.datatable').on('click', '.comment-outward_dispatch', function (e) {
        var id = $(this).data('outward-dispatch-id')
        var title = $(this).attr('title')
        var json = {
            url: "/overseers/outward_dispatches/" + id + "/render_modal_form?title=" + title,
            modalId: '#addComment',
            className: '.cancellation-form-modal',
            buttonClassName: '.confirm-cancel',
            this: $(this),
            title: title
        }
        callAjaxFunction(json)


    })
}

export default index