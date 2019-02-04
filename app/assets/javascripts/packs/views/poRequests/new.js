import bindRatingModalTabClick from "../common/bindRatingModalTabClick"
import updateRatingForm from "../common/updateRatingForm"
import updateRowTotal from "../salesOrders/updateRowTotal"


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
    updateRowTotal();

}

let onProductChange = (container) => {
    let optionSelected = $("option:selected", container);
    let row = $(container).closest('.po-request-row');
    if (optionSelected.exists() && optionSelected.val() !== '') {
        $.getJSON({
            url: Routes.get_product_details_overseers_product_path(optionSelected.val()),

            success: function (response) {
                console.log(response)
                row.find('[name*=brand]').val(response.brand);
                row.find('[name*=tax_rate_id]').val(response.tax_rate_id).trigger("change");
                row.find('[name*=measurement_unit]').val(response.measurement_unit);
                row.find('[name*=unit_price]').val(response.converted_unit_selling_price);
            }
        });
    }
};

export default newAction