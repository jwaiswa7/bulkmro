const massLeadDateUpdate = () => {
    // $('.update_lead_date_wrapper').hide();
    // toggleCheckboxes();

    $('#update_lead_date').click((event) => {
        updateLeadDate();
    });
};

let updateLeadDate = () => {
    let po_request_rows = [];
    $('input[type=checkbox][name="po_request_rows[]"]:checked').each((index, element) => {
        po_request_rows.push($(element).val());
    });

    let lead_date = $('input[name*=common_lead_date]').val();
    console.log("ELEMENT", lead_date, $('input[name*=common_lead_date]').val());
    if (lead_date == '') {
        $.notify({
            message: 'Please Choose a Lead Date to Assign'
        }, {
            type: 'danger'
        });
    }

    if (po_request_rows.length == 0) {
        $.notify({
            message: 'Please select a po request row to update lead date'
        }, {
            type: 'danger'
        });
    }

    if (po_request_rows.length > 0 && lead_date != '') {

        let data = JSON.stringify({po_request_rows: po_request_rows, common_lead_date: lead_date});
        $.ajax({
            url: Routes.update_lead_date_in_rows_overseers_po_request_path(po_request_rows),
            type: "POST",
            data: data,
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function () {
                // var dataTable = $('.datatable').dataTable();
                // dataTable.api().ajax.reload(null, false);
                // $('#all_inward_dispatches').removeAttr('checked');
                // $('#all_inward_dispatches').prop("checked", false);
                $.notify({
                    message: 'Lead Date has been successfully updated'
                }, {
                    type: 'success'
                });
            }
        });
    }
};


export default massLeadDateUpdate