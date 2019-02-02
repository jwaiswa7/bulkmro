import bindRatingModalTabClick from "../common/bindRatingModalTabClick"
import updateRatingForm from "../common/updateRatingForm"
const newAction = () => {

    bindRatingModalTabClick();
    $('.rating-modal a').click();

    var customTabSelector =  $('#multipleRatingForm .custom-tab')
    updateRatingForm();

    $('form').on('change', 'select[name*=product_id]', function (e) {
        onProductChange(this);
    }).find('select[name*=product_id]').each(function (e) {
        onProductChange(this);
    });
}

let onProductChange = (container) => {
    let optionSelected = $("option:selected", container);
    let select = $(container).closest('select');
    if (optionSelected.exists() && optionSelected.val() !== '') {
        // $.getJSON({
        //     url: Routes.autocomplete_suppliers_overseers_product_path(optionSelected.val()),
        //
        //     success: function (response) {
        //         select.closest('div.form-row').find('[name*=bp_catalog_name]').val(response.bp_catalog_name);
        //     }
        // });
        $.getJSON({
            url: Routes.get_product_details_overseers_product_path(optionSelected.val()),

            success: function (response) {
                console.log(response)
                select.closest('div.form-row').find('[name*=brand]').val(response.brand);
                // select.closest('div.form-row').find('[name*=tax_code_id]').val(response.tax_code_id).trigger("change");
                select.closest('div.form-row').find('[name*=tax_rate_id]').val(response.tax_rate_id).trigger("change");
                select.closest('div.form-row').find('[name*=measurement_unit]').val(response.measurement_unit);
                select.closest('div.form-row').find('[name*=product_unit_selling_price]').val(response.converted_unit_selling_price);
            }
        });
    }
};

export default newAction