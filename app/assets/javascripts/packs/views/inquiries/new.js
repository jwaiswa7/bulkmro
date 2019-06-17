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
};

var onBillingAddressChange = function onBillingAddressChange(container) {
    var optionSelected = $("option:selected", container);
    if (optionSelected.exists() && optionSelected.val() !== '') {
        $.getJSON({
            url: Routes.is_sez_params_overseers_addresses_path(),
            data: {
                address_id: optionSelected.val()
            },
            success: function success(response) {
                $('select#inquiry_is_sez option[value="'+response.is_sez+'"').prop('selected','selected')
            }
        });

    }
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

export default newAction