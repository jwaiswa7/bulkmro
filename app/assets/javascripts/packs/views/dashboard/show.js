import callAjaxFunction from "../common/callAjaxFunction";
import disableBackdateOption from "../common/disableBackdateOption";

const show = () => {
    $('.datatable').on('click', '.update-followup', function (e) {
        var id = $(this).data('inquiry-id');
        var json = {
            url: Routes.render_followup_edit_form_overseers_inquiry_path(id),
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

    $('.datatable').on('click', '.revise-committed-delivery-date', function (e) {
        var id = $(this).data('sales-order-id');
        var json = {
            url: Routes.render_committed_date_revision_form_overseers_sales_order_path(id),
            modalId: '#revise-committed-delivery-date',
            className: '.revise-committed-delivery-date',
            buttonClassName: '.confirm',
            this: $(this),
            title: ''
        };
        callAjaxFunction(json);

        $('.revise-committed-delivery-date').on('shown.bs.modal', function() {
            disableBackdateOption($('#sales_order_revised_committed_delivery_date'));
            if($('.sales_order_revised_committed_delivery_date').val() != null){
                $('input[name*=revised_committed_delivery_attachments]').attr("required", true);
            }
        });
    });
};

export default show