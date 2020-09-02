const onSupplierPoTypeChange = () => {
    $("[id^='drop-ship-address']").show();
    $("[id^='warehouse-addresses']").find('select').attr('required', false);
    $("[id^='warehouse-addresses']").find('select').attr('disabled', true);

    $('form').on('change', 'select[name*=supplier_po_type]', function (e) {
        let supplierId = parseInt($(this).data('supplier-id'));
        let supplierPoType = $(this).val();
        let warehouseAddressElement = $('#warehouse-addresses-'+supplierId).find('select');
        let dropshipAddressElement = $('#drop-ship-address-'+supplierId).find('select');

        if (supplierPoType == 'Drop Ship') {
            $('#warehouse-addresses-'+supplierId).hide();
            warehouseAddressElement.attr('disabled', true);
            warehouseAddressElement.attr('required', false);

            $('#drop-ship-address-'+supplierId).show();
            dropshipAddressElement.removeAttr('disabled');
            dropshipAddressElement.attr('required', true);
        } else {
            $('#warehouse-addresses-'+supplierId).show();
            warehouseAddressElement.removeAttr('disabled');
            warehouseAddressElement.attr('required', true);

            $('#drop-ship-address-'+supplierId).hide();
            dropshipAddressElement.attr('disabled', true);
            dropshipAddressElement.attr('required', false);
        }

    });

};
export default onSupplierPoTypeChange