const onScrollandClickSideMenu = () => {
    if ($('.bmro-nav-ul').length == 0){
        var topHeight = $('.bmro-head-bg').height() + 69;
    }else{
        var topHeight = $('.bmro-nav-ul').height() + $('.bmro-head-bg').height() + 69;
    }

    $('.side-menu-click').on('click', function() {
        let dataValueAttr = $(this).attr('data-path')
        $('html, body').animate({
            scrollTop: $('#'+dataValueAttr).offset().top - topHeight
        }, 1000)
    });

    document.addEventListener('scroll', function() {
        $('.target-scroll').each(function() {
            if( $(window).scrollTop() >= ($(this).offset().top-topHeight-1)) {
                let id = $(this).attr('id');
                $('.bmro-li-right').addClass('bmro-active-li',1000);
                $('label[data-path='+ id +']').parent('.bmro-li-right').removeClass('bmro-active-li');
            }
        });
    });
}

export default onScrollandClickSideMenu