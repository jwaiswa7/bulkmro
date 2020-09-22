

const index = () => {
    $(' #create_ar_invoice').hide();
    toggleCheckboxes();

    $('#create_ar_invoice').unbind('click').bind('click', function() {
        createArInvoice();
    })
    $('.datatable').on('click', '.able_to_create_ar_invoice', function (e) {
        $('#order_number').html($(this).attr('data-sales-order-number'))
        $('#arInvoiceStatusModal').modal('show')
    })

};

let toggleCheckboxes = () => {
    $('table').on('change', 'input[type=checkbox][name="the_delivery_challans[]"]', (event) => {
        showOrHideActions();
    })
}


let createArInvoice = () => {
    let delivery_challans = {};
    $('input[type=checkbox][name="the_delivery_challans[]"]:checked').each((index, element) => {
        delivery_challans[$(element).val()] = $(element).data("so-id");
    });

    if (checkValues(delivery_challans) == true) {
        let data = {delivery_challan_ids: Object.keys(delivery_challans), so_id: Object.values(delivery_challans)[0]};
        window.open(Routes.new_overseers_ar_invoice_request_path(data));
    } else {
        $.notify({
            message: 'Selected Delivery Challans Requests should be of the same Sales Order'
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
    $('input[type=checkbox][name="the_delivery_challans[]"]').each((index, element) => {
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

export default index