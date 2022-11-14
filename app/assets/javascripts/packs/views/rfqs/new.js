import select2s from "../../components/select2s";

const newAction = () => {

    $('form').on('change', 'select[name*=shipping_company_id]', function (e) {
        let reset = true;
        onShippingCompanyChange(this, reset);
    }).find('select[name*=shipping_company_id]').each(function (e) {
        let reset = false;
        onShippingCompanyChange(this, reset);
    });

    $('form').on('change', 'select[name*=billing_company_id]', function (e) {
        let reset = true;
        onBillingCompanyChange(this, reset);
    }).find('select[name*=billing_company_id]').each(function (e) {
        let reset = false;
        onBillingCompanyChange(this, reset);
    });

};

let onShippingCompanyChange = (container, reset) => {
    let optionSelected = $("option:selected", container);

    if (optionSelected.exists() && optionSelected.val() !== '') {

        if (reset) {
            $("#customer_rfq_shipping_address_id").val(null);
        }

        $('#customer_rfq_shipping_address_id').removeAttr('disabled', false);
        $('#customer_rfq_shipping_address_id').attr('data-source', Routes.autocomplete_customers_company_addresses_path(optionSelected.val())).select2('destroy');
        select2s();   
    }
};

let onBillingCompanyChange = (container, reset) => {
    let optionSelected = $("option:selected", container);

    if (optionSelected.exists() && optionSelected.val() !== '') {

        if (reset) {
            $("#customer_rfq_billing_address_id").val(null);
        }

        $('#customer_rfq_billing_address_id').removeAttr('disabled', false);
        $('#customer_rfq_billing_address_id').attr('data-source', Routes.autocomplete_customers_company_addresses_path(optionSelected.val())).select2('destroy');

        select2s();   
    }
};
export default newAction