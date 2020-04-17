
const notificationsPanel=function(){
    $(document).ready(function () {
        $("#notifications").trigger('click');
    });

$(".bmro-all-notification").click(function () {
    $('.bmro-all-notification').removeClass('active-menu');
    $(this).addClass('active-menu', 1000);
});
$(".bmro-all-action").click(function () {
    $('.bmro-all-sec').removeClass('bmro-hide');
    $('.bmro-notification-sec').addClass('bmro-hide');
    $('.bmro-comments-sec').addClass('bmro-hide');
});
$(".bmro-notification-action").click(function () {
    $('.bmro-all-sec').addClass('bmro-hide');
    $('.bmro-notification-sec').removeClass('bmro-hide');
    $('.bmro-comments-sec').addClass('bmro-hide');
});
$(".bmro-Comments-action").click(function () {
    $('.bmro-all-sec').addClass('bmro-hide');
    $('.bmro-notification-sec').addClass('bmro-hide');
    $('.bmro-comments-sec').removeClass('bmro-hide');
});
}

export default notificationsPanel;