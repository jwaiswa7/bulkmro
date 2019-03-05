const updateLogisticsOwner = () => {
    $('.update_logistics_owner_wrapper').hide();
    toggleCheckboxes();

    $('#update_logistics_owner').click((event) => {
        updateOwner();
    });

};

let toggleCheckboxes = () => {
    $('#all_purchase_orders').prop("checked", false);

    $('#all_purchase_orders').change((event) => {
        var $element = $(event.target);
        if ($element.is(':checked')) {
            $('input[type=checkbox][name="purchase_orders[]"]').each((index, element) => {
                //$(element).attr('checked', 'checked')
                $(element).prop("checked", true);
                showOrHideActions();
            });
        } else {
            $('input[type=checkbox][name="purchase_orders[]"]').each((index, element) => {
                //$(element).removeAttr('checked')
                $(element).prop("checked", false);
                showOrHideActions();
            });
        }
    });

    $('table').on('change', 'input[type=checkbox][name="purchase_orders[]"]', (event) => {
        showOrHideActions();
    })
};

let updateOwner = () => {
    let purchase_orders = [];
    $('input[type=checkbox][name="purchase_orders[]"]:checked').each((index, element) => {
        purchase_orders.push($(element).val());
    });

    let logistics_owner_id = $('select[name*=logistics_owner]').val();
    if (logistics_owner_id == '') {
        $.notify({
            message: 'Please Choose an Logistics Owner to Assign'
        }, {
            type: 'danger'
        });
    }

    if (purchase_orders.length == 0) {
        $.notify({
            message: 'Please Select any Material Followup Request you want to update'
        }, {
            type: 'danger'
        });
    }

    if (purchase_orders.length > 0 && logistics_owner_id != '') {

        var data = JSON.stringify({purchase_orders: purchase_orders, logistics_owner_id: logistics_owner_id});
        $.ajax({
            url: Routes.update_logistics_owner_overseers_purchase_orders_path(),
            type: "POST",
            data: data,
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function () {
                var dataTable = $('.datatable').dataTable();
                dataTable.api().ajax.reload(null, false);
                $('#all_purchase_orders').removeAttr('checked');
                $('#all_purchase_orders').prop("checked", false);
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

    if ($('input[type=checkbox][name="purchase_orders[]"]:checked').length > 0) {
        $('.update_logistics_owner_wrapper').show();
    } else {
        $('.update_logistics_owner_wrapper').hide();
    }

};

export default updateLogisticsOwner