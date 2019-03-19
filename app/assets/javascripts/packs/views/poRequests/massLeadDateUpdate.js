const updateLogisticsOwner = () => {
    $('.update_logistics_owner_wrapper').hide();
    // toggleCheckboxes();

    $('#update_logistics_owner').click((event) => {
        updateOwner();
    });
};


let updateOwner = () => {
    let inward_dispatches = [];
    $('input[type=checkbox][name="the_inward_dispatches[]"]:checked').each((index, element) => {
        inward_dispatches.push($(element).val());
    });

    let logistics_owner_id = $('select[name*=logistics_owner]').val();
    if (logistics_owner_id == '') {
        $.notify({
            message: 'Please Choose an Logistics Owner to Assign'
        }, {
            type: 'danger'
        });
    }

    if (inward_dispatches.length == 0) {
        $.notify({
            message: 'Please Select any Material Pickup Request you want to update'
        }, {
            type: 'danger'
        });
    }

    if (inward_dispatches.length > 0 && logistics_owner_id != '') {

        let data = JSON.stringify({inward_dispatches: inward_dispatches, logistics_owner_id: logistics_owner_id});
        $.ajax({
            url: Routes.update_logistics_owner_for_inward_dispatches_overseers_purchase_orders_path(),
            type: "POST",
            data: data,
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function () {
                var dataTable = $('.datatable').dataTable();
                dataTable.api().ajax.reload(null, false);
                $('#all_inward_dispatches').removeAttr('checked');
                $('#all_inward_dispatches').prop("checked", false);
                $.notify({
                    message: 'Logistics Owner has been successfully updated'
                }, {
                    type: 'success'
                });
            }
        });
    }
};