import callAjaxFunction from "./callAjaxFunction";

const commanComment = function(model_name, model_name_plural){
    $('.datatable').on('click', '.comment-'+ model_name, function (e) {
        var id = $(this).data('model-id')
        var title = $(this).attr('data-title')
        var json = {
            url: "/overseers/"+model_name_plural+"/" + id + "/render_modal_form?title=" + title,
            modalId: '#addComment',
            className: '.open-modal-form',
            buttonClassName: '.confirm-cancel',
            this: $(this),
            title: title
        }
        callAjaxFunction(json)
    })
}

export default commanComment