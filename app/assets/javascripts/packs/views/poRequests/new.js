import onSupplierPoTypeChange from "./onSupplierPoTypeChange"
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

    $('form').on('change', '.supplier-po-type',function () {
        onPoTypeChange('.supplier-po-type');
    });

    updateRowTotal();
    onSupplierPoTypeChange();

}

let onPoTypeChange = (container) => {
    let optionSelected = $("option:selected", container);
    let inquiryID = $('.supplier-po-type').data('inquiry-id')
    if (optionSelected.exists() && optionSelected.val() == 'Drop Ship') {
        $.get({
            url: Routes.dropbox_ship_to_overseers_inquiry_po_requests_path(inquiryID),
            data: {
                drop_ship: true
            }
        });
    }
};

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
        let supplierId = parseInt(optionSelected.val());
        let warehouseAddressElement = $('form').find('div[id*=warehouse-addresses]').attr('id', 'warehouse-addresses-'+supplierId);
        let dropShipAddressElement = $('form').find('div[id*=drop-ship-address]').attr('id', 'drop-ship-address-'+supplierId);
        warehouseAddressElement.find('select').attr('required', false);
        warehouseAddressElement.find('select').attr('disabled', true);
        onSupplierPoTYpeChangeStock(supplierId, warehouseAddressElement, dropShipAddressElement);
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

let onSupplierPoTYpeChangeStock = (supplierId, warehouseAddElement, dropShipAddressElement) => {

    $('form').on('change', 'select[name*=supplier_po_type]', function (e) {

        let supplierPoType = parseInt($(this).val());
        let warehouseAddressElement = warehouseAddElement.find('select');
        let dropshipAddressElement = dropShipAddressElement.find('select');

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

export default newAction