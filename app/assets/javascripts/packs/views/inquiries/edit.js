import newAction from "./new";
import onScrollandClickSideMenu from '../common/ScrollandClickSideMenu';

const edit = () => {
    newAction();

    $('.duplicate-inquiry').on('click', function () {
        gtag('event', 'click-duplicate', {event_category: 'duplicate-inquiry', event_label: 'Duplicate Inquiry'})
    })

    // $('.bmro-list-button').unbind('click').bind('click',function () {
    //     let page = $(this).data('path');
    //     slideTo(page);
    // })

    $('form').on('change', 'select[id*=inquiry_status]', function (e) {
        var selectedValue = $("option:selected").val();
        if (selectedValue == "Order Lost" || selectedValue == "Regret Request") {
            $("#regret-field").removeClass('d-none');
            $( "select[name*='lost_regret_reason'] option" ).removeClass('disabled')
            $("#inquiry_lost_regret_reason").attr("required", true);
            $("#inquiry_comments_attributes_0_message").attr("required", true);
        } else {
            $("#regret-field").addClass('d-none')
            $( "select[name*='lost_regret_reason'] option" ).addClass('disabled')
        }
    })

    // var top = $('.bmro-card-header').offset().top - parseFloat($('.bmro-card-header').css('marginTop').replace(/auto/, 0));
    var footTop = $('.bmro-product-bottom').offset().top - parseFloat($('.bmro-product-bottom').css('marginTop').replace(/auto/, 0));

    var maxY = footTop - $('.bmro-card-header').outerHeight();

    $(window).scroll(function(evt) {
        var y = $(this).scrollTop();

        if (y < maxY) {
            $('.bmro-card-header').removeAttr('style');
        } else {

            $('.bmro-card-header').css({
                position: 'relative',
                // top: (maxY - top) + 'px'
                top:'1360px'
            });
        }
    });
    onScrollandClickSideMenu();

};

    // end
// crezenta js

// slider js
// $(".bmro-li-right").click(function(){
//     $('.bmro-li-right').addClass('bmro-active-li',1000);
//     $(this).removeClass('bmro-active-li');
// });

export default edit
