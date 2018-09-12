const updateOnSelect = () => {
    $('form').on('change', 'select[name*=inquiry_product_supplier_id]', function (e) {
        onSupplierChange(this);
    })
};

let onSupplierChange = function (container) {
    let optionSelected = $("option:selected", container);
    let select = $(container).closest('select');

    $.each(optionSelected.data(), function(k, v) {
        select.closest('div.row').find('[name*=' + underscore(k) + ']').val(v);
    });

    select.closest('div.row').find('[name*=margin_percentage]').change();
};

export default updateOnSelect