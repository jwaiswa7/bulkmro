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
  
          if (y < maxY) {
              $('.bmro-card-header').addClass('fixed').removeAttr('style');
          } else {
              
              $('.bmro-card-header').removeClass('fixed').css({
                  position: 'relative',
                  // top: (maxY - top) + 'px'
                  top:'1940px'
              });
          }
      } else {
          $('.bmro-card-header').removeClass('fixed');
      }
  });
});      

// $(document).ready(function() {
//     var inputs = $(".bmro-form-input-text-wrap");
//     $.each(inputs)(function(index,value){
//       if(currentText.length > 30)
//         return currentText.substr(0, 30)+"...";
//       else
//         return currentText;

//       console.log(inputs[index].val());
//     });
// });


  // var arrNumber = new Array();
  // $(".bmro-form-input-text-wrap option:selected").each(function(){
  //    if($(this).text().length>15){
  //     var t = $(this).text().substr(0,15)+"...";
  //     $(this).text(t);
  //    }


  // })

var inputEmail = document.querySelector('#bmro-text-wrap');
// substring
inputEmail.onChange = function(e) {
    var max = 5;
  
    if(inputEmail.value.length > max) {
      inputEmail.value = inputEmail.value.substr(0, max)+"...";
    }
  
};

export default edit