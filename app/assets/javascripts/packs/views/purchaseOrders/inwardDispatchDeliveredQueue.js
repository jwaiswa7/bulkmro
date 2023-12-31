
import updateLogisticsOwner from"./inwardDispatchPickupQueue"

const inwardDispatchDeliveredQueue = () => {
    $('#create_invoice').hide();
    toggleCheckboxes()
    $('#create_invoice').click((event) => {
        createInvoiceRequest();
    });
    updateLogisticsOwner();
};
let toggleCheckboxes = () => {
    $('table').on('change', 'input[type=checkbox][name="the_inward_dispatches[]"]', (event) => {
        showOrHideActions();
    })
}

let createInvoiceRequest = () => {
    let inward_dispatches = {};
    $('input[type=checkbox][name="the_inward_dispatches[]"]:checked').each((index, element) => {
        inward_dispatches[$(element).val()] = $(element).data("po-id");
    });

    if (checkValues(inward_dispatches) == true) {
        let data = {ids: Object.keys(inward_dispatches), purchase_order_id: Object.values(inward_dispatches)[0]};
        window.open(Routes.new_overseers_invoice_request_path(data));
    } else {
        $.notify({
            message: 'Selected Inward Dispatches Requests should be of the same Purchase Order'
        }, {
            type: 'danger'
        });
    }

};


let checkValues = (obj) => {
    return Object.keys(obj).every((k) => obj[k] == Object.values(obj)[0])
}

let showOrHideActions = () => {
    var hide = true;
    $('input[type=checkbox][name="the_inward_dispatches[]"]').each((index, element) => {
        if ($(element).is(':checked')) {
            hide = false;
        }
    });
    if (hide) {
        $('#create_invoice').hide();
    } else {
        $('#create_invoice').show();
    }
}

export default inwardDispatchDeliveredQueue