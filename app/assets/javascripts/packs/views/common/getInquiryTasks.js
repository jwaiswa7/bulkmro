import clickOnCompose from "./clickOnCompose";

const getInquiryTasks = function () {
    $(".inquiry").click(function (e) {
        let inquiry_number = $(this).data('inquiry');
        e.preventDefault();
        $('.bmro-inquries-main').addClass('bmro-bg-color');
        $('.bmro-Inquries-task').removeClass('bmro-active-white');
        $(this).parent().parent().addClass('bmro-active-white', 1000);
        $('.bmro-show-star').addClass('bmro-inquiry-show-hide');
        $('.bmro-reset-button').removeClass('bmro-inquiry-show-hide');
        $.ajax({
            url: Routes.get_inquiry_tasks_overseers_dashboard_path({format: "html"}),
            type: "GET",
            data: {
                inquiry_number: inquiry_number
            },
            success: function (data) {
                $('.inquiry-tasks').empty();
                $('.inquiry-tasks').append(data);
                $('.bmro-order-action').removeClass('bmro-order-hide');
                $('.bmro-all-task-action').addClass('bmro-order-hide');
                clickOnCompose()
                // $('.bmro-Inquries-task').removeClass('bmro-active-white');
                // $this.addClass('bmro-active-white');
                // $('.bmro-reset-button').addClass('bmro-inquiry-show-hide');
            },
        });
    });
};

export default getInquiryTasks;