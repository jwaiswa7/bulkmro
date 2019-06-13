import select2s from "../../components/select2s";

const newAction = () => {
    $('form').on('change', 'select[name*=shipping_company_id]', function (e) {
        let reset = true;
        onShippingCompanyChange(this, reset);
    }).find('select[name*=shipping_company_id]').each(function (e) {
        let reset = false;
        onShippingCompanyChange(this, reset);
    });

    $('form').on('change', 'select[name*=company_id]', function (e) {
        let reset = true;
        onCompanyChange(this, reset);
    }).find('select[name*=company_id]').each(function (e) {
        let reset = false;
        onCompanyChange(this, reset);
    });
};

let onShippingCompanyChange = (container, reset) => {
    let optionSelected = $("option:selected", container);

    if (optionSelected.exists() && optionSelected.val() !== '') {
        if (reset) {
            $("#inquiry_shipping_address_id, #inquiry_shipping_contact_id").val(null).trigger("change");
        }

        $('#inquiry_shipping_address_id').attr('data-source', Routes.autocomplete_overseers_company_addresses_path(optionSelected.val())).select2('destroy');
        $('#inquiry_shipping_contact_id').attr('data-source', Routes.autocomplete_overseers_company_contacts_path(optionSelected.val())).select2('destroy');

        select2s();
    }
};

let onCompanyChange = (container, reset) => {
    let optionSelected = $("option:selected", container);
    if (optionSelected.exists() && optionSelected.val() !== '') {
        $.getJSON
        (
            {
                url: Routes.get_account_overseers_company_path(optionSelected.val()),
                success: function (response) {
                    var billing_address = document.getElementById('billing-address-id')
                    var shipping_address = document.getElementById('shipping-address-id')
                    if(billing_address!= null && shipping_address!= null){
                        $(billing_address).removeAttr('disabled', false)
                        $(shipping_address).removeAttr('disabled', false)
                    }
                    $('#inquiry_account_id').val(response.account_id);
                    $('#inquiry_account').val(response.account_name);
                }
            }
        );

        if (reset) {
            $("#inquiry_contact_id, #inquiry_shipping_contact_id").val(null);
        }

        $('#inquiry_contact_id').attr('data-source', Routes.autocomplete_overseers_company_contacts_path(optionSelected.val())).select2('destroy');
        $('#inquiry_shipping_contact_id').attr('data-source', Routes.autocomplete_overseers_company_contacts_path(optionSelected.val())).select2('destroy');

        select2s();

    }
};

export default newAction