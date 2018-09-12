const updateUnitCostPriceOnSelect = () => {
    $('form').on('change', 'select[name*=inquiry_product_supplier_id]', function (e) {
        onSupplierChange(this);
    })
};

let onSupplierChange = function (container) {
    let optionSelected = $("option:selected", container);
    let select = $(container).closest('select');
    select.closest('div.row').find('[name*=unit_cost_price]').val(optionSelected.data("unit-cost-price"));
    select.closest('div.row').find('[name*=margin_percentage]').val(15).change();
};

export default updateUnitCostPriceOnSelect