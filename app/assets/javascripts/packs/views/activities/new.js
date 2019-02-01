const newAction = () => {
    if($('.existing-company').hasClass('d-none')){
        $('.new-company-form').find('select, input').attr('required', false)
        $('#activity_company_id').attr('required', true)
    }
    else if($('.new-company').hasClass('d-none')){
        $('.new-company-form').find('[name="activity[company_creation_request_attributes][name]"]').attr('required', true)
        $('#activity_company_id').attr('required', false)
    }

    $('.new-company').unbind('click').bind('click', function (event) {
        event.stopPropagation();
        $('.new-company-form, .existing-company-form,.existing-company ').removeClass('d-none');
        $('.existing-company-form, .new-company').addClass('d-none');
        $('#activity_company_id').val('').trigger('change');
        $('[name="activity[company_creation_request_attributes][name]"]').attr('required', true)
        $('#activity_company_id').attr('required', false)

    })
    $('.existing-company').unbind('click').bind('click', function (event) {
        event.stopPropagation();
        $('.new-company-form, .existing-company-form,.new-company ').removeClass('d-none');
        $('.new-company-form, .existing-company').addClass('d-none');
        $('.new-company-form').find('select, input').attr('required', false)
        $('#activity_company_id').attr('required', true)
    })


}
export default newAction