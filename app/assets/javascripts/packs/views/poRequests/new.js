
import updateRowTotal from "./updateRowTotal"
import select2s from "../../components/select2s";


const newAction = () => {

    $('form').on('change', 'select[name*=product_id]', function (e) {
        onProductChange(this);
    }).find('select[name*=product_id]').each(function (e) {
        onProductChange(this);
    });
    $('form').on('change', 'select[name*=supplier_id]', function (e) {
        let reset = true;
        onSupplierChange(this, reset);
    }).find('select[name*=supplier_id]').each(function (e) {
        let reset = false;
        onSupplierChange(this, reset);
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
                row.find('[name*=brand]').val(response.brand);
                row.find('[name*=tax_rate_id]').val(response.tax_rate_id).trigger("change");
                row.find('[name*=measurement_unit]').val(response.measurement_unit);
                row.find('[name*=unit_price]').val(response.converted_unit_selling_price);
            }
        });
    }
};

let onSupplierChange = (container, reset) => {
    let optionSelected = $("option:selected", container);
    if (optionSelected.exists() && optionSelected.val() !== '') {
        if (reset) {
            $('form').find('select[name*=bill_from_id]').val(null).trigger("change");
            $('form').find('select[name*=ship_from_id]').val(null).trigger("change");
            $('form').find('select[name*=contact_id]').val(null).trigger("change");
        }
        $('form').find('select[name*=bill_from_id]').attr('data-source', Routes.autocomplete_overseers_company_addresses_path(optionSelected.val())).select2('destroy');
        $('form').find('select[name*=ship_from_id]').attr('data-source', Routes.autocomplete_overseers_company_addresses_path(optionSelected.val())).select2('destroy');
        $('form').find('select[name*=contact_id]').attr('data-source', Routes.autocomplete_overseers_company_contacts_path(optionSelected.val())).select2('destroy');

        select2s();
    }
};

export default newAction