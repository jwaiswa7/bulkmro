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

    $('form').on('change', 'select[id*=inquiry_status]', function (e) {
        var selectedValue = $("option:selected").val();
        if (selectedValue == "Order Lost" || selectedValue == "Regret") {
            $("#regret-field").removeClass('d-none');
            $( "select[name*='lost_regret_reason'] option" ).removeClass('disabled')
            $("#inquiry_lost_regret_reason").attr("required", true);
            $("#inquiry_comments_attributes_0_message").attr("required", true);
        } else {
            $("#regret-field").addClass('d-none')
            $( "select[name*='lost_regret_reason'] option" ).addClass('disabled')
        }
    })

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

export default edit


// crezenta js

function slideTo(page) {
    let element = document.getElementById(page);
    element.scrollIntoView({behavior: "smooth", block: "start", inline: "nearest"});
}
    $(".bmro-li-right").click(function(){
    $('.bmro-li-right').addClass('bmro-active-li',1000);
    $(this).removeClass('bmro-active-li');
});

$(function() {
  var top = $('.bmro-card-header').offset().top - parseFloat($('.bmro-card-header').css('marginTop').replace(/auto/, 0));
  var footTop = $('.bmro-product-bottom').offset().top - parseFloat($('.bmro-product-bottom').css('marginTop').replace(/auto/, 0));

  var maxY = footTop - $('.bmro-card-header').outerHeight();

  $(window).scroll(function(evt) {
      var y = $(this).scrollTop();
      if (y > top) {
          
//Quand scroll, ajoute une classe ".fixed" et supprime le Css existant 
          if (y < maxY) {
              $('.bmro-card-header').addClass('fixed').removeAttr('style');
          } else {
              
//Quand la sidebar arrive au footer, supprime la classe "fixed" précèdement ajouté
              $('.bmro-card-header').removeClass('fixed').css({
                  position: 'relative',
                  // top: (maxY - top) + 'px'
                  top:'2100.39px'
              });
          }
      } else {
          $('.bmro-card-header').removeClass('fixed');
      }
  });
});      

$(function() {
    $('.bmro-icon-table').parent().addClass('bmro-icon-parent');
    console.log('check')
});