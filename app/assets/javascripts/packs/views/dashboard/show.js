import callAjaxFunction from "../common/callAjaxFunction";
import disableBackdateOption from "../common/disableBackdateOption";

const show = () => {
    $('.datatable').on('click', '.update-followup', function (e) {
        var id = $(this).data('inquiry-id');
        var json = {
            url: "/overseers/inquiries/" + id + "/render_followup_edit_form",
            modalId: '#update-followup-date',
            className: '.followup',
            buttonClassName: '.confirm',
            this: $(this),
            title: ''
        };
        callAjaxFunction(json);
        $(this).focus(function() {
            disableBackdateOption($('#inquiry_quotation_followup_date'), false);
        });
    });
};

export default show