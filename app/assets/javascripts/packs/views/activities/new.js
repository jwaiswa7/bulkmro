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
};
export default newAction