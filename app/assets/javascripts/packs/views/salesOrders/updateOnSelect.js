const updateOnSelect = () => {
    $('form').on('change', 'select[name*=sales_quote_row_id]', function (e) {
        onSalesQuoteRowChange(this);
    })
};

let onSalesQuoteRowChange = function (container) {
    let optionSelected = $("option:selected", container);
    let select = $(container).closest('select');

    $.each(optionSelected.data(), function(k, v) {
        select.closest('div.row').find('[name*=' + underscore(k) + ']').val(v);
    });
};

export default updateOnSelect