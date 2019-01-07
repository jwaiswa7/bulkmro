const newAction = () => {
    $('.new-company').unbind('click').bind('click', function (event) {
        event.stopPropagation();
        $('.new-company-form').toggle(1500,"easeOutQuint")
    })

    $('#select2-activity_company_id-results  li:eq(0)').before('<li><button type="button" class="btn btn-info new-company"> add new company </button></li>');
}
export default newAction