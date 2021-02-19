import select2s from "../../components/select2s";
import deleteRow from "./deleteRowbutton";

const nextStepAction = () => {
  $('#other_reason').hide();

  $('form').on('change', 'select[id*=dc_reasons]', function (e) {
    if ($(this).select2('data')[0].text == "Other") {
      $('#other_reason').show();
    } else {
      $('#other_reason').find('textarea').val("")
      $('#other_reason').hide();
    }
  })
    var dataAttributes = $('body').data();
    var controllerAction = camelize(dataAttributes.controllerAction);
    if( controllerAction == "nextStep")
    {
        $('#delivery_challan_customer_request_attachment').prop('required',true);
        $('.error').text('Attachment is required')
    }
    else {
        $('#delivery_challan_customer_request_attachment').prop('required',false);
        $('.error').text('');
    }

    deleteRow();

    $('.delivery_challan_rows_quantity').on('input', function(e){
      e.preventDefault();
      let currentElement = $(this);
      let input = currentElement.find('input').val();
      let maxQuantity = currentElement.find('input').attr('max');

      if(typeof input !== undefined ){
        if(parseFloat(input) > parseFloat(maxQuantity)){
          currentElement.find('.text-error').remove();
          currentElement.append("<span class='text-error text-danger'>Please enter a value less than or equal to" + maxQuantity + ".</span>")
        } else {
          currentElement.find('.text-error').remove();
        }
      }
    })
};

export default nextStepAction