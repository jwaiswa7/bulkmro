import productsSupplierRating from "../products/productSupplierRating"
const editSuppliers = () => {
    $('form[action$=update_suppliers]')
        .on('change', 'select[name*=supplier_id]', function (e) {
            onSupplierChange(this);
        })
        .on('click', '.update-with-best-price', function (e) {
            let parent = $(this).closest('.input-group');
            let input = parent.find('input');
            parent.closest('div.form-row').find('[name*="[unit_cost_price]"]').val(input.val());
        })
        .find('select[name*=supplier_id]')
        .each(function (e) {
            onSupplierChange(this);
        });

    $('#select_all_suppliers').change(function () {
        $('input[name="inquiry_product_ids[]"]').each(function () {
            $(this).prop('checked', $('#select_all_suppliers').prop("checked")).trigger('change');
        });
    });
};

let onSupplierChange = (container) => {
    let optionSelected = $("option:selected", container);
    let select = $(container).closest('select');

    if (optionSelected.exists() && optionSelected.val() !== '') {
        $.getJSON({
            url: Routes.best_prices_and_supplier_bp_catalog_overseers_product_path(select.data('product-id')),
            data: {
                supplier_id: optionSelected.val(),
                inquiry_product_supplier_id: select.data('inquiry-product-supplier-id')
            },

            success: function (response) {
                var rating = (response.rating === null) ? 0 : response.rating;
                select.closest('div.form-row').find('[name*=lowest_unit_cost_price]').val(response.lowest_unit_cost_price);
                select.closest('div.form-row').find('[name*=latest_unit_cost_price]').val(response.latest_unit_cost_price);
                select.closest('div.form-row').find('[name*=bp_catalog_name]').val(response.bp_catalog_name);
                select.closest('div.form-row').find('[name*=bp_catalog_sku]').val(response.bp_catalog_sku);
                select.closest('div.form-row').find(".render-star").text(rating)
            }
        });
    }
};

export default editSuppliers