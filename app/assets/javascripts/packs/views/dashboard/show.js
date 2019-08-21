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
        $('.followup').on('shown.bs.modal', function() {
            disableBackdateOption($('#inquiry_quotation_followup_date'));
        });
    });
};

export default show