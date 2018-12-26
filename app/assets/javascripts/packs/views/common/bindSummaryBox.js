// to set the status filter upon selected status

const bindSummaryBox = function (classname, select) {
    $(classname).on('click', function (e) {
        let value = $(this).data('value');
        let selectBox = $(select).find('select');
        selectBox.val(value).trigger('change');
        e.preventDefault();
        return false;
    });
};

export default bindSummaryBox