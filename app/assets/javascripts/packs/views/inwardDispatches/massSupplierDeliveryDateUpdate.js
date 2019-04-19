import disableBackdateOption from "../common/disableBackdateOption";

const massSupplierDeliveryDateUpdate = () => {
    $('.update_supplier_delivery_date_wrapper').hide();
    toggleCheckboxes();

    $('#update_supplier_delivery_date').click((event) => {
        updateSupplierDeliveryDate();
    });
};

let toggleCheckboxes = () => {
    $('#all_supplier_delivery_dates').prop("checked", false);

    $('#all_supplier_delivery_dates').change((event) => {
        var $element = $(event.target)
        if ($element.is(':checked')) {
            $('input[type=checkbox][name="row[]"]').each((index, element) => {
                $(element).prop("checked", true);
                showOrHideActions();
            });
        } else {
            $('input[type=checkbox][name="row[]"]').each((index, element) => {
                $(element).prop("checked", false);
                showOrHideActions();
            });
        }
    });

    $('body').on('change', 'input[type=checkbox][name="row[]"]', (event) => {
        showOrHideActions();
    })
}

let updateSupplierDeliveryDate = () => {
    let supplier_delivery_date = $('input[name*=common_supplier_delivery_date]').val();
    if (supplier_delivery_date == '') {
        $.notify({
            message: 'Please Choose a Supplier Delivery Date to Assign'
        }, {
            type: 'danger'
        });
    }

    let selectedInwardDispatchRows = $('input[type=checkbox][name="row[]"]:checked');
    if (selectedInwardDispatchRows.length > 0 && supplier_delivery_date != '') {
        selectedInwardDispatchRows.each((index, element) => {
            let container = $(element).closest('.inward-dispatch-row');
            $(container).find('input[name$="supplier_delivery_date]"]').val(supplier_delivery_date);
        });
        $('#all_supplier_delivery_dates').removeAttr('checked');
        $('#all_supplier_delivery_dates').prop("checked", false);
    }

    if (selectedInwardDispatchRows.length == 0) {
        $.notify({
            message: 'Please select a row to update Supplier Delivery date'
        }, {
            type: 'danger'
        });
    }
};


let showOrHideActions = () => {
    let hide = true;

    if ($('input[type=checkbox][name="row[]"]:checked').length > 0) {
        $('.update_supplier_delivery_date_wrapper').show();
        disableBackdateOption($('input[name*=common_supplier_delivery_date]'));
    } else {
        $('.update_supplier_delivery_date_wrapper').hide();
    }

}

export default massSupplierDeliveryDateUpdate