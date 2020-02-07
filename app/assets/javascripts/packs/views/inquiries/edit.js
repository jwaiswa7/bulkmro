import newAction from "./new";

const edit = () => {
    newAction();
    $('form').on('change', 'select[name*=product_id]', function (e) {
        onProductChange(this);
    }).find('select[name*=product_id]').each(function (e) {
        onProductChange(this);
    });

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
let onProductChange = (container) => {
    let optionSelected = $("option:selected", container);
    let select = $(container).closest('select');

    if (optionSelected.exists() && optionSelected.val() !== '') {
        $.getJSON({
            url: Routes.customer_bp_catalog_overseers_product_path(optionSelected.val()),
            data: {
                company_id: $('#inquiry_company_id').val()
            },

            success: function (response) {
                select.closest('div.form-row').find('[name*=bp_catalog_name]').val(response.bp_catalog_name);
                select.closest('div.form-row').find('[name*=bp_catalog_sku]').val(response.bp_catalog_sku);
            }
        });
    }   
};
    // end      
// crezenta js

// slider js
// $(".bmro-li-right").click(function(){
//     $('.bmro-li-right').addClass('bmro-active-li',1000);
//     $(this).removeClass('bmro-active-li');
// });
let onScrollandClickSideMenu = () => {
    let topHeight = $('.bmro-nav-ul').height() + $('.bmro-head-bg').height() + 70

    $('.bmro-company-summary').click(function() {
        $('html, body').animate({
            scrollTop: $(".bmro-company-summary-slide").offset().top - 200
        }, 1000)
    }),
    $('.bmro-Produts-summary').click(function (){
            $('html, body').animate({
                scrollTop: $(".bmro-Produts-summary-slide").offset().top
            }, 1000)
        }),

    $('.bmro-Opportunity-Details').click(function (){
            $('html, body').animate({
                scrollTop: $(".bmro-Opportunity-Details-slide").offset().top - topHeight
            }, 1000)
        })

    $('.bmro-Billing').click(function (){
        $('html, body').animate({
            scrollTop: ($(".bmro-Billing-slide").offset().top)-topHeight
        }, 1000)
    })

    $('.bmro-owner-details').click(function (){
        $('html, body').animate({
            scrollTop: $(".bmro-owner-details-slide").offset().top - topHeight
        }, 1000)
    })

    $('.bmro-order-details-slide').click(function (){
        $('html, body').animate({
            scrollTop: $(".bmro-order-slide").offset().top - topHeight
        }, 1000)
    })

    $('.bmro-important').click(function (){
        $('html, body').animate({
            scrollTop: $(".bmro-important-slide").offset().top - topHeight
        }, 1000)
    })

    $('.bmro-slide-top').click(function (){
        $('html, body').animate({
            scrollTop: $(".bmro-top-slide").offset().top - 200
        }, 1000)
    })

    $('.bmro-product-slide').click(function (){
        $('html, body').animate({
            scrollTop: $(".bmro-product-slide-on").offset().top - 200
        }, 1000)
    })

    $('.bmro-new-slide').click(function (){
        $('html, body').animate({
            scrollTop: $(".bmro-new-slide-on").offset().top - 200
        }, 1000)
    })

    $('.bmro-invoice-one').click(function(){
        $(this).parent().toggleClass('bmro-parent-bg')
    })

    document.addEventListener('scroll', function() {
        $('.target-scroll').each(function() {
            if( $(window).scrollTop() >= ($(this).offset().top-topHeight-1)) {
                var id = $(this).attr('id');
                $('.bmro-li-right').addClass('bmro-active-li',1000);
                $('label[data-path='+ id +']').parent('.bmro-li-right').removeClass('bmro-active-li');
            }
        });
    });
}

export default edit