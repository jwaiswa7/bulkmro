import getStatusRecords from "./getStatusRecords";
import getInquiryTasks from "./getInquiryTasks";
import resetButton from "./resetButton";
import dropdownInquiryArrow from "./inquiryDropdown";

const statusBox = function () {
    $(".status-box").click(function (e) {
        let inquiry_status = $(this).data('status');
        let pagination = $(this).data('pagination');
        let executive_link = typeof $(".status-box").data('executive-link')  !== 'undefined'
        $('.bmro-same-box').removeClass('bmro-same-box-active');
        $(this).addClass('bmro-same-box-active', 1000);
        e.preventDefault();
        $('.sub-content-sales-height').empty();
        let loader=`<div class="sales-loader"><div class="sprint-loader-wrapper"><i class="sprint-loader"></i></div></div>`;
        $('.sub-content-sales-height').append(loader);
        $('.sales-loader').show();
        $.ajax({
            url: Routes.get_filtered_inquiries_overseers_dashboard_path({format: "html"}),
            type: "GET",
            data: {
                status: inquiry_status,
                executive_link: executive_link,
                pagination: pagination
            },
            success: function (data) {
                $('.inquiries-card').empty();
                $('.inquiries-card').append(data);
                getInquiryTasks();
                getStatusRecords();
                resetButton();
                dropdownInquiryArrow();
            },
        });
    });
}

export default statusBox;