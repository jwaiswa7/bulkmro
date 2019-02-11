const index = () => {
    $('.update_logistics_owner_wrapper').hide();
    toggleCheckboxes();

    $('#update_logistics_owner').click((event) => {
        updateLogisticsOwner();
    });

};

let toggleCheckboxes = () => {
    $('#all_po_requests').prop("checked", false);

    $('#all_po_requests').change((event) => {
        var $element = $(event.target)
        if ($element.is(':checked')) {
            $('input[type=checkbox][name="po_requests[]"]').each((index, element) => {
                //$(element).attr('checked', 'checked')
                $(element).prop("checked", true);
                showOrHideActions();
            });
        } else {
            $('input[type=checkbox][name="po_requests[]"]').each((index, element) => {
                //$(element).removeAttr('checked')
                $(element).prop("checked", false);
                showOrHideActions();
            });
        }
    });

    $('table').on('change', 'input[type=checkbox][name="po_requests[]"]', (event) => {
        showOrHideActions();
    })
}

let updateLogisticsOwner = () => {
    let po_requests = [];
    $('input[type=checkbox][name="po_requests[]"]:checked').each((index, element) => {
        po_requests.push($(element).val());
    });

    let logistics_owner_id = $('select[name*=logistics_owner]').val();
    if (logistics_owner_id == '') {
        $.notify({
            message: 'Please Choose an Logistics Owner to Assign'
        }, {
            type: 'danger'
        });
    }

    if (po_requests.length == 0) {
        $.notify({
            message: 'Please Select any PO Request you want to update'
        }, {
            type: 'danger'
        });
    }

    if (po_requests.length > 0 && logistics_owner_id != '') {

        var data = JSON.stringify({po_requests: po_requests, logistics_owner_id: logistics_owner_id});
        $.ajax({
            url: Routes.update_logistics_owner_overseers_po_requests_path(),
            type: "POST",
            data: data,
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function () {
                var dataTable = $('.datatable').dataTable();
                dataTable.api().ajax.reload(null, false);
                $('#all_po_requests').removeAttr('checked');
                $('#all_po_requests').prop("checked", false);
                $.notify({
                    message: 'Logistics Owner has been successfully updated'
                }, {
                    type: 'success'
                });
            }
        });
    }


};


let showOrHideActions = () => {
    let hide = true;

    if ($('input[type=checkbox][name="po_requests[]"]:checked').length > 0) {
        $('.update_logistics_owner_wrapper').show();
    } else {
        $('.update_logistics_owner_wrapper').hide();
    }

}

export default index