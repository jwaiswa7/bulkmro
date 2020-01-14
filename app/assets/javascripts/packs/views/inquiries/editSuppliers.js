import productsSupplierRating from "../products/productSupplierRating"
import addSuppliers from "./addSuppliers";

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
            // onSupplierChange(this);
        });

    $('#select_all_products').change(function () {
        $('input[name="inquiry_product_ids[]"]').each(function () {
            console.log($(this));
            $(this).prop('checked', $('#select_all_products').prop("checked")).trigger('change');
        });
    });

    $('#select_all_suppliers').change(function () {
        $('input[name="inquiry_product_supplier_ids[]"]').each(function () {
            $(this).prop('checked', $('#select_all_suppliers').prop("checked")).trigger('change');
        });
    });
    massLinkSupplier();
    addSuppliers();
    draftRfq();
    deleteIsp();
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
                var rating = (response.rating === null) ? 0 : response.rating.toFixed(1)
                select.closest('div.form-row').find('[name*=lowest_unit_cost_price]').val(response.lowest_unit_cost_price);
                select.closest('div.form-row').find('[name*=latest_unit_cost_price]').val(response.latest_unit_cost_price);
                select.closest('div.form-row').find('[name*=bp_catalog_name]').val(response.bp_catalog_name);
                select.closest('div.form-row').find('[name*=bp_catalog_sku]').val(response.bp_catalog_sku);
                select.closest('div.form-row').find(".render-star").text(rating)
            }
        });
    }
};

let massLinkSupplier = () => {
    $('.mass-link-supplier').click(function () {
        $('#masslinksupplier').modal('show');
        let products = [];
        $.each($("input[name='inquiry_product_ids[]']:checked"), function () {
            products.push($(this).val());
        });
        $('#product_ids').val(products);
    });
};

let draftRfq = () => {
    let product_ids = [];
    let inquiry_product_ids = [];
    let inquiry_id = $('input[name=inquiry_id]').val();

    $('.draft-rfq').click(function () {
        let inquiry_product_supplier_ids = [];
        let inquiry_id = $('input[name=inquiry_id]').val();
        $.each($("input[name='inquiry_product_supplier_ids[]']:checked"), function () {
            let $this = $(this);
            let selector = $this.closest('.product_wrapper').find($('input[name="inquiry_product_ids[]"]'));
            let product_id = selector.attr('id').split('inquiry_product_id_')[1];
            product_ids.push(product_id);
            inquiry_product_supplier_ids.push($this.attr('id').split('inquiry_product_supplier_id_')[1]);
        });

        $.each(product_ids, function (i, j) {
            if ($.inArray(j, inquiry_product_ids) == -1) {
                inquiry_product_ids.push(j);
            }
        });
        let data = {
            inquiry_product_ids: inquiry_product_ids,
            inquiry_product_supplier_ids: inquiry_product_supplier_ids
        };

        $.ajax({
            url: Routes.add_supplier_rfqs_overseers_inquiry_supplier_rfqs_path(inquiry_id),
            type: "POST",
            data: data,
            success: function () {

            }
        });
    });
};

let deleteIsp = () => {
    $('.delete-isp').on('click', function () {
        let $this = $(this);
        let inquiry_id = $('input[name=inquiry_id]').val();
        let inquiry_product_supplier_id = $this.attr('id');
        let data = {
            inquiry_product_supplier_id: inquiry_product_supplier_id
        };
        $.ajax({
            url: Routes.destroy_supplier_overseers_inquiry_path(inquiry_id),
            type: "POST",
            data: data,
            success: function () {

            }
        });
    })
}

export default editSuppliers