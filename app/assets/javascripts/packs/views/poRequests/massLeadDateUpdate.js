import disableBackdateOption from "../common/disableBackdateOption";

const massLeadDateUpdate = () => {
    $('.update_lead_date_wrapper').hide();
    toggleCheckboxes();

    $('#update_lead_date').click((event) => {
        updateLeadDate();
    });
};

let toggleCheckboxes = () => {
    $('input[type=checkbox][id^=all_lead_dates_]').prop("checked", false);

    $('input[type=checkbox][id^="all_lead_dates_"]').change((event) => {
        var selectAllParentDivId = event.target.getAttribute('id').replace('all_lead_dates_','.supplier-parent-div-')
        var concatenatedStringWithParentDivID = selectAllParentDivId.concat(' input[type=checkbox][name="po_request_row[]"]')

        if ($(event.target).is(':checked')) {
            $(concatenatedStringWithParentDivID).each((index, element) => {
                $(element).prop("checked", true);
            });
        } else {
            $(concatenatedStringWithParentDivID).each((index, element) => {
                $(element).prop("checked", false);
            });
        }
        showOrHideActions(selectAllParentDivId);
    });

    $('input[type=checkbox][id^="po_request_row_id_"]').change((event) => {
        var parentDivId = event.target.getAttribute('data-parent-div-id')
        showOrHideActions(parentDivId)
    })
}

let updateLeadDate = () => {
    let lead_date = $('input[name*=common_lead_date]').val();
    if (lead_date == '') {
        $.notify({
            message: 'Please Choose a Lead Date to Assign'
        }, {
            type: 'danger'
        });
    }

    let selectedPoRequestRows = $('input[type=checkbox][name="po_request_row[]"]:checked');
    if (selectedPoRequestRows.length > 0 && lead_date != '') {
        selectedPoRequestRows.each((index, element) => {
            let container = $(element).closest('.po-request-row');
            $(container).find('input[name$="lead_time]"]').val(lead_date);
        });
        $('#all_lead_dates').removeAttr('checked');
        $('#all_lead_dates').prop("checked", false);
    }

    if (selectedPoRequestRows.length == 0) {
        $.notify({
            message: 'Please select a po request row to update lead date'
        }, {
            type: 'danger'
        });
    }
};


let showOrHideActions = (parentDiv) => {
    let hide = true;

    var divUpdateLeadDateWrapper = parentDiv.concat(' .update_lead_date_wrapper')
    var checkedBox = $(parentDiv.concat(' input[type=checkbox][name="po_request_row[]"]:checked'))
    if ($(checkedBox).length > 0) {
        $(divUpdateLeadDateWrapper).show();
        disableBackdateOption($('input[name*=common_lead_date]'));
    } else {
        $(divUpdateLeadDateWrapper).hide();
    }

}

export default massLeadDateUpdate