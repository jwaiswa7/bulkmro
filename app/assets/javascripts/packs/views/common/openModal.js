import callAjaxFunction from "./callAjaxFunction";

const openModal = () => {
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

        $('.revise-committed-delivery-date').on('shown.bs.modal', function () {
            disableBackdateOption($('#sales_order_revised_committed_delivery_date'));
            if ($('.sales_order_revised_committed_delivery_date').val() != null) {
                $('input[name*=revised_committed_delivery_attachments]').attr("required", true);
            }
        });
    });
};

export default openModal