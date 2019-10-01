// to set the status filter upon selected status

const bindSummaryBox = function (classname, select) {
    $(".bmro-click-toggle").click(function(){
        $(this).parent().toggleClass("bmro-collaps2-bg");
    });

    $(classname).on('click', function (e) {
        let value = $(this).data('value');
        let selectBox = $(select).find('select');
        selectBox.val(value).trigger('change');
        e.preventDefault();
        return false;
    });
};

export default bindSummaryBox