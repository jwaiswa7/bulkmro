const updateStatus = () => {
    $('.update_payment_status_wrapper').hide();
    toggleCheckboxes();

    $('#update_payment_status').click((event) => {
        updateOwner();
    });

};

let toggleCheckboxes = () => {
    $('#all_payment_requests').prop("checked", false);

    $('#all_payment_requests').change((event) => {
        var $element = $(event.target)
        if ($element.is(':checked')) {
            $('input[type=checkbox][name="payment_requests[]"]').each((index, element) => {
                //$(element).attr('checked', 'checked')
                $(element).prop("checked", true);
                showOrHideActions();
            });
        } else {
            $('input[type=checkbox][name="payment_requests[]"]').each((index, element) => {
                //$(element).removeAttr('checked')
                $(element).prop("checked", false);
                showOrHideActions();
            });
        }
    });

    $('table').on('change', 'input[type=checkbox][name="payment_requests[]"]', (event) => {
        showOrHideActions();
    })
}

let updateOwner = () => {
    let payment_requests = [];
    $('input[type=checkbox][name="payment_requests[]"]:checked').each((index, element) => {
        payment_requests.push($(element).val());
    });
    let status_id = $('select[name*=status]').val();
    if (status_id == '') {
        $.notify({
            message: 'Please Choose an Payment status to Update'
        }, {
            type: 'danger'
        });
    }

    if (payment_requests.length == 0) {
        $.notify({
            message: 'Please Select any Payment Request you want to update'
        }, {
            type: 'danger'
        });
    }

    if (payment_requests.length > 0 && status_id != '') {

        var data = JSON.stringify({payment_requests: payment_requests, status_id: status_id});
        $.ajax({
            url: Routes.update_payment_status_overseers_payment_requests_path(),
            type: "POST",
            data: data,
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function () {
                var dataTable = $('.datatable').dataTable();
                dataTable.api().ajax.reload(null, false);
                $('#all_payment_requests').removeAttr('checked');
                $('#all_payment_requests').prop("checked", false);
                $.notify({
                    message: 'Payment status is successfully updated'
                }, {
                    type: 'success'
                });
            }
        });
    }


};


let showOrHideActions = () => {
    let hide = true;

    if ($('input[type=checkbox][name="payment_requests[]"]:checked').length > 0) {
        $('.update_payment_status_wrapper').show();
    } else {
        $('.update_payment_status_wrapper').hide();
    }

}

export default updateStatus