import getStatusRecords from "./getStatusRecords";
import getInquiryTasks from "./getInquiryTasks";

const statusBox = function () {
    $(".status-box").click(function (e) {
        let inquiry_status = $(this).data('status');
        $('.bmro-same-box').removeClass('bmro-same-box-active');
        $(this).addClass('bmro-same-box-active', 1000);
        e.preventDefault();
        $.ajax({
            url: Routes.get_filtered_inquiries_overseers_dashboard_path({format: "html"}),
            type: "GET",
            data: {
                status: inquiry_status
            },
            success: function (data) {
                $('.inquiries-card').empty();
                $('.inquiries-card').append(data);
                getInquiryTasks();
                getStatusRecords();
            },
        });
    });


    $(".status-box-sales-manager").click(function (e) {
        let inquiry_status = $(this).data('status');
        $('.bmro-same-box').removeClass('bmro-same-box-active');
        $(this).addClass('bmro-same-box-active', 1000);
        e.preventDefault();
        $.ajax({
            url: Routes.get_filtered_inquiries_overseers_dashboard_path({format: "html"}),
            type: "GET",
            data: {
                status: inquiry_status
            },
            success: function (data) {
                $('.inquiries-card').empty();
                $('.inquiries-card').append(data);
                getInquiryTasks();
                getStatusRecords();
            },
        });
    });
}

export default statusBox;