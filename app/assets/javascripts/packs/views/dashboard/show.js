import callAjaxFunction from "../common/callAjaxFunction";
import disableBackdateOption from "../common/disableBackdateOption";
import newdashboardload from "../common/newSalesDashboard";
import newsalesManagerDashboard from "../common/newsalesManagerDashboard";
import clickOnCompose from "../common/clickOnCompose";

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

    $(".select_account").change(function (e) {
        let account_exe = $(this).val();
        e.preventDefault();
        $.ajax({
            url: Routes.get_account_executive_data_overseers_dashboard_path({format: "html"}),
            type: "GET",
            data: {
                account_exe: account_exe
            },
            success: function (data) {
                $('.leftside-html').empty();
                $('.bmro-dash-leftside').addClass('bmro-order-hide');
                $('.leftside-html').append(data);
                clickOnCompose()
                newdashboardload();
            },
        });
    });

};

export default show