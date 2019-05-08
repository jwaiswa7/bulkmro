const hideRemoveBtnRows = function () {
    $('.remove_nested_fields_link').unbind('click').bind('click',function(){
        if($(this).data('id') == '1'){$('.remove_nested_fields_link').addClass('d-none')}
    })
};
export default hideRemoveBtnRows