import disableBackdateOption from "../common/disableBackdateOption";

const newAction = () => {
    if($('.existing-company').hasClass('d-none')){
        $('.new-company-form').find('select, input').attr('required', false);
        $('#activity_company_id').attr('required', true)
    }
    else if($('.new-company').hasClass('d-none')){
        $('.new-company-form').find('[name="activity[company_creation_request_attributes][name]"]').attr('required', true);
        $('#activity_company_id').attr('required', false)
    }

    $('.new-company').unbind('click').bind('click', function (event) {
        event.stopPropagation();
        $('.new-company-form, .existing-company-form,.existing-company ').removeClass('d-none');
        $('.existing-company-form, .new-company').addClass('d-none');
        $('.new-contact').addClass('d-none');
        $('#activity_company_id').val('').trigger('change');
        $('[name="activity[company_creation_request_attributes][name]"]').attr('required', true);
        $('#activity_company_id').attr('required', false)
        $('.new-contact-form').find('input').attr('required', false);

    });

    $('.existing-company').unbind('click').bind('click', function (event) {
        event.stopPropagation();
        $('.new-company-form, .existing-company-form,.new-company ').removeClass('d-none');
        $('.new-company-form, .existing-company').addClass('d-none');
        $('.new-contact').removeClass('d-none');
        $('.new-company-form').find('select, input').attr('required', false);
        $('#activity_company_id').attr('required', true)
    });

    $('.new-contact').unbind('click').bind('click', function (event) {
        event.stopPropagation();
        $('.activity_contact').toggle();
        if ($('.new-contact-form').hasClass('d-none')) {
            $('.new-contact-form').removeClass('d-none');
        } else {
            $('.new-contact-form').addClass('d-none');
        }
    });

    $('#activity_company_creation_request_attributes_create_new_contact').click( function () {
        if ($(this).is(":checked")) {
            $('.activity_contact').addClass('d-none');
        } else {
            $('.activity_contact').removeClass('d-none');
        }
    });

    

    if ($('#activity_purpose').select2('data')[0].text == "Others") {
        $("#activity_purpose_others").prop("required", true);
        $("#activity_purpose_others").prop("disabled", false);
    }
    else{
        $("#activity_purpose_others").val('');
    }

    $('#activity_purpose').on('select2:select', function (e) {
        if ($(this).select2('data')[0].text != "Others") {
          $("#activity_purpose_others").val('');
          $("#activity_purpose_others").prop("disabled", true);
          $("#activity_purpose_others").attr("required", false);
          $("#activity_purpose_others").parent().children().removeClass('is-invalid');
          $("#activity_purpose_others").parent().find('span .select2-selection').removeClass('is-invalid');
        } else {
          $("#activity_purpose_others").prop("required", true);
          $("#activity_purpose_others").prop("disabled", false);
        }
      });
      
      $('#activity_date').on("focus", function () {
        var newDate = Date.parse(new Date())
        disableBackdateOption($('#activity_date'),true,moment(newDate).subtract(15, 'days').format('DD-MMM-YYYY'));
    });
};
export default newAction