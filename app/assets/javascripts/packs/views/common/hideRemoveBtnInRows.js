const hideRemoveBtnRows = function () {
    $('.remove_nested_fields_link').unbind('click').bind('click',function(){
        if($('.remove_nested_fields_link').length == 2){$('.remove_nested_fields_link').addClass('d-none')}
    })
};
export default hideRemoveBtnRows