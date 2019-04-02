import disableBackdateOption from './../common/disableBackdateOption'

const validatePoRequestAddresses = () => {
       window.Parsley.addValidator('locations', {
        validateString: function (_value, locations, parsleyInstance) {
            var locations = locations.split(',');
            var supplier_po_type = $(parsleyInstance.$element[0]).closest('div.po-request-form').find('select[name*=supplier_po_type]').val();

            var selectedWarehouse = $(parsleyInstance.$element[0]).find(':selected').data('warehouse');
            var selectedWarehouseState = $(parsleyInstance.$element[0]).find(':selected').data('warehouse-state');
            var selectedBillingSupplierState = $(parsleyInstance.$element[0]).closest('div.po-request-form').find('[name*=bill_from_id] :selected').data('supplier-state');
            var selectedShippingSupplierState = $(parsleyInstance.$element[0]).closest('div.po-request-form').find('[name*=ship_from_id] :selected').data('supplier-state');

            var selectedBillToCity = $(parsleyInstance.$element[0]).closest('div.po-request-form').find('[name*=bill_to_id] :selected').data('warehouse-city');
            var selectedShipToCity = $(parsleyInstance.$element[0]).closest('div.po-request-form').find('[name*=ship_to_id] :selected').data('warehouse-city');

            var warehouseStates = $(parsleyInstance.$element[0]).data('warehouse-list').split(',');

            if (selectedBillingSupplierState && selectedShippingSupplierState && !warehouseStates.includes(selectedBillingSupplierState) && !warehouseStates.includes(selectedShippingSupplierState)) {
                return selectedWarehouseState == locations[2];
            }

            if (supplier_po_type == "Regular" && selectedBillToCity == selectedShipToCity) {
                return true;
            }



            if ((supplier_po_type == "Route Through" || supplier_po_type == "Drop Ship") && selectedWarehouse == locations[0]) {
                return true;
            }

            return false
        },
        messages: {
            en: 'Selected Location should be in the same City / State as order\'s City / State Or Must be the Sales Order Bill From'
        }
    });

    disableBackdateOption($('.supplier-committed-date'), false);

    disableBackdateOption($('.lead-time'));
    $('body').on("fields_added.nested_form_fields", function (e, params) {
        disableBackdateOption($('.lead-time'));
    })
};

export default validatePoRequestAddresses