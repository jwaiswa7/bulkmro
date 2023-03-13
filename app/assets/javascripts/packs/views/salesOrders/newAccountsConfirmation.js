
const newAccountsConfirmation = () => {
    $('.account-approval').prop('disabled', true);
    // $('.account-rejection').click();
    // $('input[type=checkbox]').removeAttr('required');

    const $selectAllCheckbox = $('#select-all-checkbox');
    const $selectableCheckboxes = $('.selectable-checkbox');

    $selectAllCheckbox.on('change', function() {
        const isChecked = $selectAllCheckbox.prop('checked');
        $selectableCheckboxes.prop('checked', isChecked);
        $selectableCheckboxes.trigger('change');
        checkCheckboxStatus()
    });

    $('.new_accounts_confirmation input[type=checkbox]').click(function (f) {
        checkCheckboxStatus();
        let target = f.currentTarget.id;
        let rejectReason = rejectReasonMapping(target);
        let $select = $('#sales_order_custom_fields_reject_reasons');
        let values = $select.val();
        let i = values.indexOf(rejectReason);

        if (f.currentTarget.checked == true) {
            $(".summary-list ."+ target).removeClass('bmro-status-cancel').addClass('dummy');
            if (i >= 0) {
                values.splice(i, 1);
                $select.val(values).change();
            }

        } else if (f.currentTarget.checked == false) {
            $(".summary-list ."+ target).removeClass('dummy').addClass('bmro-status-cancel');
            values.push(rejectReason);
            $select.val(values).change();

        }
    });

    $('.account-rejection').click(function () {
        $('input[type=checkbox]').removeAttr('required');
    });
};



let checkCheckboxStatus = () => {
    if ($('.new_accounts_confirmation input[type="checkbox"][required]').not(':checked').length == 0) {
        $('#salesOrderApproverMessage').modal('show')
        if ($('#salesOrderApproverMessage').length == 0){
            $('.account-approval').prop('disabled', false);
            if (!$('.account-approval').hasClass('disabled')){
                $('#internal-comments').removeClass('show')
            }
            $('.account-rejection').addClass('disabled');
            $('#sales_order_custom_fields_reject_reasons').removeAttr('required');
        }

    }else if ($('.new_accounts_confirmation input[type="checkbox"]').not(':checked').length == 1 && $('.account-rejection').hasClass('collapsed')){
        $('.account-rejection').click();
        $('.account-rejection').removeClass('disabled');
        $('.account-approval').prop('disabled', true);
        $('#sales_order_custom_fields_reject_reasons').attr('required', 'required');
    }else{
        $('.account-approval').prop('disabled', true);
        $('.account-rejection').removeClass('disabled');
        $('#sales_order_custom_fields_reject_reasons').attr('required', 'required');
    }


};

let rejectReasonMapping = (param) => {
    let hash = {
        "sales_order_confirm_purchase_order_number": "Wrong PO Number",
        "sales_order_confirm_payment_terms": "Wrong Payment Terms",
        "sales_order_confirm_billing_warehouse": "Wrong Billing Warehouse",
        "sales_order_confirm_shipping_warehouse": "Wrong Shipping Warehouse",
        "sales_order_confirm_billing_address": "Wrong Billing Address",
        "sales_order_confirm_shipping_address": "Wrong Shipping Address",
        // "sales_order_confirm_attachments": "Wrong Attachments",
        "sales_order_confirm_hsn_codes": "Wrong HSN Codes",
        "sales_order_confirm_tax_rates": "Wrong Tax Rates",
        "sales_order_confirm_tax_types": "Wrong Tax Types",
        "sales_order_confirm_ord_values": "Wrong Order Values",
        "sales_order_confirm_billing_warehouse_gst": "Wrong Billing Warehouse GST",
        "sales_order_confirm_billing_address_gst": "Wrong Billing Address GST",
        "sales_order_confirm_shipping_warehouse_gst": "Wrong Shipping Warehouse GST",
        "sales_order_confirm_shipping_address_gst": "Wrong Shipping Address GST",
        "sales_order_confirm_billing_warehouse_pincode": "Wrong Billing Warehouse Pincode",
        "sales_order_confirm_billing_address_pincode": "Wrong Billing Address Pincode",
        "sales_order_confirm_shipping_warehouse_pincode": "Wrong Shipping Warehouse Pincode",
        "sales_order_confirm_shipping_address_pincode": "Wrong Shipping Address Pincode",
        "sales_order_confirm_delivery_dates": "Wrong Delivery Dates",
        "sales_order_confirm_order_quantity": "Wrong Order Quantity",
        "sales_order_confirm_unit_price": "Wrong Unit Price",
        "sales_order_confirm_customer_order_date": "Wrong Customer Order Date",
        "sales_order_confirm_customer_name": "Wrong Customer Name"





    };
    Object.freeze(hash);

    return hash[param]
};

export default newAccountsConfirmation
