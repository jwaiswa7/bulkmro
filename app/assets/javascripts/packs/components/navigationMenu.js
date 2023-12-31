const navigationMenu = () => {
    // $(".bmro-menu-click").click(function () {
    //     $('.bmro-dash-main-menu').toggleClass('bmro-dash-main-menu-show');
    //     $(this).toggleClass('bmro-menu-roted');
    // })
    // $('.bmro-main-drop-col p').hover(function(){
    //     $(this).children('.bmro-dash-hover').css("display","block");
    // }, function() {
    //     $(this).children('.bmro-dash-hover').css("display","none");
    // })
    // $(".bmro-dashbord-click").click(function () {
    //     $('.bmro-dash-main-menu').removeClass('bmro-dash-main-menu-show');
    //     $('.bmro-menu-click').removeClass('bmro-menu-roted');
    // })
    // $(".bmro-dash-main-menu").mouseleave(function() {
    //     $(".bmro-dash-main-menu").removeClass('bmro-dash-main-menu-show');
    // });
    // $(".dropdown-menu").mouseleave(function() {
    //     $('.dropdown-toggle').parent().removeClass('dropdown-show');
    // })
    // $('.bmro-dropdown-item').click(function(){
    //     $('.dropdown-toggle').parent().removeClass('dropdown-show');
    // })
    $('.dropdown-toggle').click(function() {
        $('.dropdown-toggle').parent().removeClass('dropdown-show');
        $(this).parent().addClass('dropdown-show',2000);
    });

    function toggleFirstLevelHeading (classname, containerName) {

        $("#" + classname).click(() => {
            let toggle = $('.bmro-main-drop-col-level-one-container .bmro-select-level-one-to-see-second-and-third').hasClass('active');
            let toggleClass = $('.bmro-second-and-third-level-headings .bmro-second-and-third-level-headings-container').hasClass('show');

            if(toggle || toggleClass) {
                $('.bmro-main-drop-col-level-one-container .bmro-select-level-one-to-see-second-and-third').toggleClass('active', false);
                $('.bmro-second-and-third-level-headings .bmro-second-and-third-level-headings-container').toggleClass('show', false);
            }

            $("#" + classname).toggleClass('active', true);
            $("#" + containerName).toggleClass('show', true);
        })

    }

    $(".bmro-dash-main-menu").mouseleave(function () {
        $('.bmro-dash-main-menu').removeClass('bmro-dash-main-menu-show');
        $('.bmro-menu-click').removeClass('bmro-menu-roted');
    });

    $(".bmro-menu-click").unbind('click').bind('click', function () {
        //console.log('kkkkkkkkkkkkkkkkkkkkkkkkk')
        if($('.bmro-dash-main-menu').hasClass("bmro-dash-main-menu-show")) {
            $('.bmro-dash-main-menu').removeClass("bmro-dash-main-menu-show")
            $(this).removeClass('bmro-menu-roted');
        } else {
            $('.bmro-dash-main-menu').addClass("bmro-dash-main-menu-show")
            $(this).addClass('bmro-menu-roted')
        }
    })

    toggleFirstLevelHeading('nav-bpartners-heading', 'bpartners_heading_container');

    toggleFirstLevelHeading('nav-catalog-heading', 'catalog_heading_container');

    toggleFirstLevelHeading('nav-sales-heading', 'sales_heading_container');

    toggleFirstLevelHeading('nav-logistics-heading', 'logistics_heading_container');

    toggleFirstLevelHeading('nav-inventory-heading', 'inventory_heading_container');

    toggleFirstLevelHeading('nav-reports-heading', 'reports_heading_container');

    toggleFirstLevelHeading('nav-admin-heading', 'admin_heading_container');

    toggleFirstLevelHeading('nav-docs-heading', 'docs_heading_container');

    toggleFirstLevelHeading('nav-favourites-heading', 'favourites_heading_container');



};
export default navigationMenu