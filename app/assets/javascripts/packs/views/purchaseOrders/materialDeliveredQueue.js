const materialDeliveredQueue = () => {
    $('#create_invoice').hide();
    toggleCheckboxes();
    $('#create_invoice').click((event) => {
        createInvoiceRequest();
    });

};

let toggleCheckboxes = () => {
    $('table').on('change', 'input[type=checkbox][name="pickup_requests[]"]', (event) => {
        showOrHideActions();
    })
};

let createInvoiceRequest = () => {
    let pickup_requests = {};
    $('input[type=checkbox][name="pickup_requests[]"]:checked').each((index, element) => {
        pickup_requests[$(element).val()] = $(element).data("po-id");
    });

    if (checkValues(pickup_requests) == true) {
        let data = {ids: Object.keys(pickup_requests), purchase_order_id: Object.values(pickup_requests)[0]};
        window.open(Routes.new_overseers_invoice_request_path(data));
    } else {
        $.notify({
            message: 'Selected Material Delivered Requests should be of the same Purchase Order'
        }, {
            type: 'danger'
        });
    }

};

let checkValues = (obj) => {
    return Object.keys(obj).every((k) => obj[k] == Object.values(obj)[0])
};

let showOrHideActions = () => {
    var hide = true;

    $('input[type=checkbox][name="pickup_requests[]"]').each((index, element) => {
        if ($(element).is(':checked')) {
            hide = false;
        }
    });
    if (hide) {
        $('#create_invoice').hide();
    } else {
        $('#create_invoice').show();
    }
};

export default materialDeliveredQueue