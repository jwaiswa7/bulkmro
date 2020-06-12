import clickOnCompose from "./clickOnCompose";
import grpoNumbervalidator from './checkGrpoNumbervalidity';

const getInquiryTasks = function () {
    $(".inquiry").click(function (e) {
        let inquiry_number = $(this).data('inquiry');
        let executive_link = typeof $(".status-box").data('executive-link')  !== 'undefined'
        e.preventDefault();
        $('.bmro-inquries-main').addClass('bmro-bg-color');
        $('.bmro-Inquries-task').removeClass('bmro-active-white');
        $(this).parent().parent().addClass('bmro-active-white', 1000);
        $('.bmro-show-star').addClass('bmro-inquiry-show-hide');
        $('.bmro-reset-button').removeClass('bmro-inquiry-show-hide');
        $('.inquiry-tasks').empty();
        let loader=`<div class="sales-loader"><div class="sprint-loader-wrapper"><i class="sprint-loader"></i></div></div>`;
        $('.inquiry-tasks').append(loader);
        $('.sales-loader').show();
        $.ajax({
            url: Routes.get_inquiry_tasks_overseers_dashboard_path({format: "html"}),
            type: "GET",
            data: {
                inquiry_number: inquiry_number,
                executive_link: executive_link
            },
            success: function (data) {
                $('.inquiry-tasks').empty();
                $('.inquiry-tasks').append(data);
                $('.bmro-order-action').removeClass('bmro-order-hide');
                $('.bmro-all-task-action').addClass('bmro-order-hide');
                clickOnCompose();
                grpoNumbervalidator();
            },
        });
    });
};

export default getInquiryTasks;