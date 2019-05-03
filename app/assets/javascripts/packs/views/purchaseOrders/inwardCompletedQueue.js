const inwardCompletedQueue = () => {
    $(' #create_ar_invoice').hide();
    toggleCheckboxes();

    $('#create_ar_invoice').unbind('click').bind('click', function() {
        createArInvoice();
    })

};

let toggleCheckboxes = () => {
    $('table').on('change', 'input[type=checkbox][name="the_inward_dispatches[]"]', (event) => {
        showOrHideActions();
    })
}


let createArInvoice = () => {
    let inward_dispatches = {};
    $('input[type=checkbox][name="the_inward_dispatches[]"]:checked').each((index, element) => {
        inward_dispatches[$(element).val()] = $(element).data("so-id");
    });

    if (checkValues(inward_dispatches) == true) {
        let data = {ids: Object.keys(inward_dispatches), so_id: Object.values(inward_dispatches)[0]};
        window.open(Routes.new_overseers_ar_invoice_request_path(data));
    } else {
        $.notify({
            message: 'Selected Inward Dispatches Requests should be of the same Sales Order'
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
    console.log('showOrHideActions')
    $('input[type=checkbox][name="the_inward_dispatches[]"]').each((index, element) => {
        if ($(element).is(':checked')) {
            hide = false;
        }
    });
    console.log(hide)
    if (hide) {
        $(' #create_ar_invoice').hide();
    } else {
        $(' #create_ar_invoice').show();
    }
}

export default inwardCompletedQueue