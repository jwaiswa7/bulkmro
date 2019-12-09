const navigationMenu = () => {
    $(".bmro-menu-click").click(function () {
        $('.bmro-dash-main-menu').toggleClass('bmro-dash-main-menu-show');
        $(this).toggleClass('bmro-menu-roted');
    })
    $('.bmro-main-drop-col p').hover(function(){
        $(this).children('.bmro-dash-hover').css("display","block");
    }, function() {
        $(this).children('.bmro-dash-hover').css("display","none");
    })
    $(".bmro-dashbord-click").click(function () {
        $('.bmro-dash-main-menu').removeClass('bmro-dash-main-menu-show');
        $('.bmro-menu-click').removeClass('bmro-menu-roted');
    })
    $(".bmro-dash-main-menu").mouseleave(function() {
        $(".bmro-dash-main-menu").removeClass('bmro-dash-main-menu-show');
    });
    $(".dropdown-menu").mouseleave(function() {
        $('.dropdown-toggle').parent().removeClass('dropdown-show');
    })
    $('.bmro-dropdown-item').click(function(){
        $('.dropdown-toggle').parent().removeClass('dropdown-show');
    })
    $('.dropdown-toggle').click(function() {
        $('.dropdown-toggle').parent().removeClass('dropdown-show');
        $(this).parent().addClass('dropdown-show',2000);
    })
};
export default navigationMenu