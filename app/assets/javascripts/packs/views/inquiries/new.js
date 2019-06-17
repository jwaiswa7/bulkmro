import select2s from "../../components/select2s";

const newAction = () => {

    $('form').on('change', 'select[name*=shipping_company_id]', function (e) {
        let reset = true;
        onShippingCompanyChange(this, reset);
    }).find('select[name*=shipping_company_id]').each(function (e) {
        let reset = false;
        onShippingCompanyChange(this, reset);
    });

    $('form').on('change', 'select[name*=billing_address_id]', function (e) {
        onBillingAddressChange(this);
    })

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

let onBillingAddressChange = function onBillingAddressChange(container) {
    let optionSelected = $("option:selected", container);
    let url = new URL(window.location.href)
    let company_id = url.searchParams.get('company_id')

    if (optionSelected.exists() && optionSelected.val() !== '' && company_id != '') {
        $.getJSON({
            url: Routes.is_sez_params_overseers_company_addresses_path(company_id),
            data: {
                address_id: optionSelected.val()
            },
            success: function success(response) {
                $('select#inquiry_is_sez option[value="' + response.is_sez + '"').prop('selected', 'selected')
            }
        });
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
                    let billing_address = document.getElementById('billing-address-id')
                    let shipping_address = document.getElementById('shipping-address-id')
                    if (billing_address != null && shipping_address != null) {
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