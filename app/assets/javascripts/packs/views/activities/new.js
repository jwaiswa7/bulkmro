const newAction = () => {
    $('.new-company-form').find('select, input').attr('required', false)
    $('.new-company').unbind('click').bind('click', function (event) {
        event.stopPropagation();
        $('.new-company-form, .existing-company-form,.existing-company ').removeClass('d-none');
        $('.existing-company-form, .new-company').addClass('d-none');
        $('[name="activity[company_creation_request_attributes][account_id]"],[name="activity[company_creation_request_attributes][name]"] ').attr('required', true)


    })
    $('.existing-company').unbind('click').bind('click', function (event) {
        event.stopPropagation();
        $('.new-company-form, .existing-company-form,.new-company ').removeClass('d-none');
        $('.new-company-form, .existing-company').addClass('d-none');
        $('.new-company-form').find('select, input').attr('required', false)
        $('.new-company-form').find("input[type=text], textarea").val("")
    })
    $('.new-account').unbind('click').bind('click', function (event) {
        event.stopPropagation();
        $('.new-account-form, .existing-account-form,.existing-account ').removeClass('d-none');
        $('.existing-account-form, .new-account').addClass('d-none');
        $('[name="activity[company_creation_request_attributes][account_id]"]').attr('required', false)
        $('.new-account-form').find('input, select').attr('required', true)



    })
    $('.existing-account').unbind('click').bind('click', function (event) {
        event.stopPropagation();
        $('.new-account-form, .existing-account-form,.new-account ').removeClass('d-none');
        $('.new-account-form, .existing-account').addClass('d-none');
        $('.new-account-form').find('input, select').attr('required', false)
        $('[name="activity[company_creation_request_attributes][account_id]"]').attr('required', true)
    })

}
export default newAction