import salesNavigationPanel from '../common/salesNavigationPanel';
import dropdownInquiryArrow from "./inquiryDropdown";
const newsalesManagerDashboard= function() {

    salesNavigationPanel();
    //$('.bmro-dash-leftside').addClass('bmro-sales-dash-leftside').removeClass('bmro-dash-leftside');
    //$('.main-pedding').addClass('main-sales-pedding').removeClass('main-pedding');
    //$('.bmro-dash-inqu').addClass('bmro-sales-dash-inqu').removeClass('bmro-dash-inqu');
    dropdownInquiryArrow();

    $(".bmro-sales-progress").each(function() {
        var value = $(this).attr('data-value')* 10;
        var leftSideCircle = $(this).find('.bmro-sales-progress-left .bmro-sales-progress-bar');
        var rightSideCircle = $(this).find('.bmro-sales-progress-right .bmro-sales-progress-bar');
        if (value > 0) {
            if (value <= 50) {
                rightSideCircle.css('transform', 'rotate(' + (360- percentageToDegrees(value)) + 'deg)')
            } else {
                rightSideCircle.css('transform', 'rotate(180deg)')
                leftSideCircle.css('transform', 'rotate(' + (360 - percentageToDegrees(value - 50)) + 'deg)')
            }
        }
    })

    function percentageToDegrees(percentage) {
        return percentage / 100 * 360
    }
    $('#performanceOverviewTable').hide();
    $('.sales-view-report').click(()=>{
        $('#salesPerformanceTables').hide();
        $('#performanceOverviewTable').show();
    })
    $('.bmro-back-arrow').click(()=>{
        $('#salesPerformanceTables').fadeIn();
        $('#performanceOverviewTable').hide();
    })

};

export default newsalesManagerDashboard