// to set the status filter upon selected status

const bindSummaryBox = function (classname, select) {
    $('.bmro-invoice-one').click(function () {
        if ($('.bmro-collaps1').hasClass("show"))
        {
            $('.bmro-invoice-box-one').hide();
            $('.bmro-invoice-box-two').hide();
        }
        else
        {
            $('.bmro-invoice-box-one').show();
            $('.bmro-invoice-box-two').hide();
        }
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