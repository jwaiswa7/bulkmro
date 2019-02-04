const validatePoRequestAddresses = () => {
    window.Parsley.addValidator('locations', {
        validateString: function (_value, locations, parsleyInstance) {
            var supplier_po_type = $(parsleyInstance.$element[0]).closest('div.po-request-form').find('select[name*=supplier_po_type]').val();

            var locations = locations.split(',');

            if (supplier_po_type == "drop_ship" || supplier_po_type == "route_through") {
                var selectedWarehouse = $(parsleyInstance.$element[0]).find(':selected').data('warehouse');
                var selectedWarehouseState = $(parsleyInstance.$element[0]).find(':selected').data('warehouse-state');
                if (selectedWarehouse == locations[0]) {
                    return true;
                } else {
                    return selectedWarehouseState == locations[2];
                }
            } else if (supplier_po_type == "regular") {
                var selectedWarehouse = $(parsleyInstance.$element[0]).find(':selected').data('warehouse');
                var selectedWarehouseState = $(parsleyInstance.$element[0]).find(':selected').data('warehouse-state');
                if (selectedWarehouse == locations[1]) {
                    return true;
                } else {
                    return selectedWarehouseState == locations[2];
                }
            }
        },
        messages: {
            en: 'Selected Location should be in the same City / State as order\'s City / State Or Must be the Sales Order Bill From'
        }
    });

    $('.supplier-committed-date').daterangepicker({
        singleDatePicker: true,
        minDate: moment(),
        locale: {
            format: 'DD-MMM-YYYY'
        }
    });
};


export default validatePoRequestAddresses