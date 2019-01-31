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
}

let createInvoiceRequest = () => {
    let pickup_requests = {};
    let url = Routes.approve_selected_overseers_activities_path();
    $('input[type=checkbox][name="pickup_requests[]"]:checked').each((index, element) => {
        pickup_requests[$(element).val()] = $(element).data("po-number");
    });

    if (checkValues(pickup_requests)) {
        alert("values match");
        var data = JSON.stringify({ids: Object.keys(pickup_requests)});
        // $.ajax({
        //     url: url,
        //     type: "POST",
        //     data: data,
        //     contentType: "application/json; charset=utf-8",
        //     dataType: "json",
        //     success: function (response) {
        //         var dataTable = $('.datatable').dataTable();
        //         dataTable.api().ajax.reload(null, false);
        //     }
        // });
    } else {
        alert("values dont match");
    }

};

let checkValues = (obj) => {
    Object.keys(obj).every((k) => obj[k] == Object.values(obj)[0])
}

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
}

export default materialDeliveredQueue