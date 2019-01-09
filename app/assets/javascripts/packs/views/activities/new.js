const newAction = () => {
    $('.new-company').unbind('click').bind('click', function (event) {
        event.stopPropagation();
        $('.new-company-form, .existing-company-form,.existing-company ').removeClass('d-none'); 
        $('.existing-company-form, .new-company').addClass('d-none'); 
    })
    $('.existing-company').unbind('click').bind('click', function (event) {
        event.stopPropagation();
        $('.new-company-form, .existing-company-form,.new-company ').removeClass('d-none'); 
        $('.new-company-form, .existing-company').addClass('d-none');  
    })
}
export default newAction