// to set the status filter upon selected status

const statusChange = function (classname, select) {
    $(classname).on('click', function (e) {
        let id = $(this).attr('id').replace("status_", "");
        let selectBox = $(select).find('select');
        let sibling = selectBox.siblings();

        selectBox.select2().val(id).trigger('change');
        sibling.removeClass('select2-container--default');
        sibling.addClass('select2-container--bootstrap');

        e.preventDefault();
        return false;
    });
};

export default statusChange