const newAction = () => {
    $('.new-company').unbind('click').bind('click', function (event) {
        event.stopPropagation();
        $('.new-company-form, .existing-company-form,.existing-company ').removeClass('d-none');
        $('.existing-company-form, .new-company').addClass('d-none');
        $('[name="activity[company_creation_request_attributes][account_id]"]').attr('required', true)

    })
    $('.existing-company').unbind('click').bind('click', function (event) {
        event.stopPropagation();
        $('.new-company-form, .existing-company-form,.new-company ').removeClass('d-none');
        $('.new-company-form, .existing-company').addClass('d-none');
        $('[name="activity[company_creation_request_attributes][account_id]"]').attr('required', false)
    })
}
export default newAction