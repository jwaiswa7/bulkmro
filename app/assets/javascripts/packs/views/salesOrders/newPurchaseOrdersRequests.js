import bindRatingModalTabClick from "../common/bindRatingModalTabClick"
import updateRatingForm from "../common/updateRatingForm"
import select2s from "../../components/select2s";

const newPurchaseOrdersRequests = () => {

    bindRatingModalTabClick();
    $('.rating-modal a').click();
    var customTabSelector = $('#multipleRatingForm .custom-tab')
    customTabSelector.eq(0).removeClass('disabled')
    customTabSelector[0].click();
    updateRatingForm();

    window.Parsley.addValidator('warehousecity', {
        validateString: function (_value, locations, parsleyInstance) {
            var supplier_po_type = $(parsleyInstance.$element[0]).closest('div.simple-row').find('select[name*=supplier_po_type]').val();

            if(supplier_po_type == "drop_ship" || supplier_po_type == "route_through"){
                var selectedWarehouse = $(parsleyInstance.$element[0]).find(':selected').data('warehouse');
                var selectedWarehouseState = $(parsleyInstance.$element[0]).find(':selected').data('warehouse-state');
                if(selectedWarehouse == locations.split(',')[0]){
                    return true
                }else{
                    return selectedWarehouseState == locations.split(',')[2]
                }
            }
            if(supplier_po_type == "regular"){
                var selectedWarehouse = $(parsleyInstance.$element[0]).find(':selected').data('warehouse');
                var selectedWarehouseState = $(parsleyInstance.$element[0]).find(':selected').data('warehouse-state');
                if(selectedWarehouse == locations.split(',')[1]){
                    return true
                }else{
                    return selectedWarehouseState == locations.split(',')[2]
                }
            }
        },
        messages: {
            en: 'Selected Bill To should be in the same city/state as order\'s city/state'
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

export default newPurchaseOrdersRequests