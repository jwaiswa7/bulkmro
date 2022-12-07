import select2s from "../../components/select2s";
const finalCheckout = () => {
    let path = window.location.href.split("=")[1];
    if (path == 'summary') {
        $('#product-summary').show();
        $('#billing-address, #shipping-address, #comments, #payment-method').hide();

    } else {
        $('#product-summary').hide();
    }

    $('[name="cart[billing_address_id]"]').on('change', function () {
        onBillingAddressChange($(this).val());

    });
    $('[name="cart[shipping_address_id]"]').on('change', function () {
        onShippingAddressChange($(this).val());
    });
    $('[name="cart[special_instructions]"]').on('change', function () {
        $('#checkout-payment-method').collapse('show');
    });

    $('[name="cart[billing_company_id]"]').on('change', function () {
        let reset = true;
        onBillingCompanyChange(this, reset);
    }).find('[name="cart[billing_company_id]"]').each(function (e) {
        let reset = false;
        onBillingCompanyChange(this, reset);
    });

    $('form').on('change', 'select[name*=shipping_company_id]', function (e) {
        let reset = true;
        onShippingCompanyChange(this, reset);
    }).find('select[name*=shipping_company_id]').each(function (e) {
        let reset = false;
        onShippingCompanyChange(this, reset);
    });

};

let onBillingAddressChange = (billing_address_id) => {
    $('#checkout-shipping').collapse('show');
    let selected_address = $('#billing_address_' + billing_address_id).html();
    $("#changed_billing_address").html(selected_address);
};


let onShippingAddressChange = (shipping_address_id) => {
    $('#checkout-comments').collapse('show');
    let selected_address = $('#shipping_address_' + shipping_address_id).html();
    $("#changed_shipping_address").html(selected_address);
};

let onBillingCompanyChange = (container, reset) => {

    let optionSelected = $("option:selected", container);
    console.log(optionSelected.val());

    if (optionSelected.exists() && optionSelected.val() !== '') {

        if (reset) {
            $("#cart_billing_address_id").val(null);
            $("#checkout_po_reference").val(null);
        }
        $('#cart_billing_address_id').removeAttr('disabled', false);
        $('#checkout_po_reference').removeAttr('disabled', false);
        $('#cart_billing_address_id').attr('data-source', Routes.autocomplete_customers_company_addresses_path(optionSelected.val())).select2('destroy');
        $('#checkout_po_reference').attr('data-source', Routes.customer_po_autocomplete_customers_company_addresses_path(optionSelected.val())).select2('destroy');

        select2s();
    }
};
let onShippingCompanyChange = (container, reset) => {
    let optionSelected = $("option:selected", container);

    if (optionSelected.exists() && optionSelected.val() !== '') {

        if (reset) {
            $("#cart_shipping_address_id").val(null);
        }
        $('#cart_shipping_address_id').removeAttr('disabled', false);
        $('#cart_shipping_address_id').attr('data-source', Routes.autocomplete_customers_company_addresses_path(optionSelected.val())).select2('destroy');
        select2s();
    }
};

export default finalCheckout