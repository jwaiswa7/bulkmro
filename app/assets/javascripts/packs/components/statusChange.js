// to set the status filter upon selected status

const statusChange = function (classname, select) {
    $(classname).on('click', function (e) {
        let id = $(this).attr('id').replace("status_", "");
        let selectBox = $(select).find('select');
        selectBox.val(id).trigger('change');

        e.preventDefault();
        return false;
    });
};

export default statusChange