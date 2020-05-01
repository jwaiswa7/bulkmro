import callAjaxFunction from "../common/callAjaxFunction";
import disableBackdateOption from "../common/disableBackdateOption";
import newdashboardload from "../common/newSalesDashboard";
import newsalesManagerDashboard from "../common/newsalesManagerDashboard";

const show = () => {

    newdashboardload();
    newsalesManagerDashboard();

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
};

export default show