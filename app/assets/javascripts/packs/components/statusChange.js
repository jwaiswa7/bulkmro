// to set the status filter upon selected status

const statusChange = function (classname, selectbox) {
    $(classname).click(function(){
        var id= $(this).attr('id').replace("status_","");
        var select_box =$(selectbox).find('select');
        select_box.select2().val(id).trigger('change')
        var sibling = select_box.siblings()
        sibling.removeClass('select2-container--default')
        sibling.addClass('select2-container--bootstrap')
    });
}

export default statusChange