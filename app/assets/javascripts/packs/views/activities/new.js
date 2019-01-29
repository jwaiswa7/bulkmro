const newAction = () => {
    $('.new-company').unbind('click').bind('click', function (event) {
        event.stopPropagation();
        $('.new-company-form, .existing-company-form,.existing-company ').removeClass('d-none');
        $('.existing-company-form, .new-company').addClass('d-none');
        $('#activity_company_id').val('').trigger('change')


    })
    $('.existing-company').unbind('click').bind('click', function (event) {
        event.stopPropagation();
        $('.new-company-form, .existing-company-form,.new-company ').removeClass('d-none');
        $('.new-company-form, .existing-company').addClass('d-none');
        $('.new-company-form').find('select, input').attr('required', false)
    })


}
export default newAction