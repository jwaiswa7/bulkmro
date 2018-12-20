// to set the status filter upon selected status

const statusChange = function (classname, select) {
    $(classname).on('click', function (e) {
        var id = $(this).attr('id').replace("status_", "");
        var selectBox = $(select).find('select');
        var sibling = selectBox.siblings();

        selectBox.select2().val(id).trigger('change');
        sibling.removeClass('select2-container--default');
        sibling.addClass('select2-container--bootstrap');

        e.preventDefault();
        return false;
    });
};

export default statusChange