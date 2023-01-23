
const editProducts = () => {

    $('form').on('change', 'select[name*=product_id]', function (e) {
        onProductChange(this);
    }).find('select[name*=product_id]').each(function (e) {
        onProductChange(this);
    });


    $(document).on("fields_added.nested_form_fields", function (event, param) {
        $('.serial_number:last').val($('.serial_number:visible').length);

      });
      $(document).on("fields_removed.nested_form_fields", function (event, param) {

        for (var i = 0; i < $('.serial_number:visible').length; i++) {
          $($('.serial_number:visible')[i]).val(i + 1)
        }
    });

}

let onProductChange = (container) => {
    let optionSelected = $("option:selected", container);
    let select = $(container).closest('select');

    if (optionSelected.exists() && optionSelected.val() !== '') {
        $.getJSON({
            url: Routes.customer_bp_catalog_overseers_product_path(optionSelected.val()),
            data: {
                company_id: $('#inquiry_company_id').val()
            },

            success: function (response) {
                select.closest('div.form-row').find('[name*=bp_catalog_name]').val(response.bp_catalog_name);
                select.closest('div.form-row').find('[name*=bp_catalog_sku]').val(response.bp_catalog_sku);
            }
        });
    }
};

export default editProducts
