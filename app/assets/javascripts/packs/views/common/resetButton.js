
const resetButton=function() {
    $(".bmro-reset-button").click(function () {
        $('.bmro-order-action').addClass('bmro-order-hide');
        $('.bmro-all-task-action').removeClass('bmro-order-hide');
        $('.bmro-inquries-main').removeClass('bmro-bg-color');
        $('.bmro-Inquries-task').removeClass('bmro-active-white');
        $('.bmro-Inquries-task').parent().removeClass('bmro-bg-color')
        $('.bmro-show-star').removeClass('bmro-inquiry-show-hide');
        $('.bmro-reset-button').addClass('bmro-inquiry-show-hide');
    });
}
export default resetButton;