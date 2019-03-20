import disableBackdateOption from "../common/disableBackdateOption";

const massLeadDateUpdate = () => {
    $('.update_lead_date_wrapper').hide();
    toggleCheckboxes();

    $('#update_lead_date').click((event) => {
        updateLeadDate();
    });
};

let toggleCheckboxes = () => {
    $('#all_lead_dates').prop("checked", false);

    $('#all_lead_dates').change((event) => {
        var $element = $(event.target)
        if ($element.is(':checked')) {
            $('input[type=checkbox][name="po_request_row[]"]').each((index, element) => {
                $(element).prop("checked", true);
                showOrHideActions();
            });
        } else {
            $('input[type=checkbox][name="po_request_row[]"]').each((index, element) => {
                $(element).prop("checked", false);
                showOrHideActions();
            });
        }
    });

    $('body').on('change', 'input[type=checkbox][name="po_request_row[]"]', (event) => {
        showOrHideActions();
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


let showOrHideActions = () => {
    let hide = true;

    if ($('input[type=checkbox][name="po_request_row[]"]:checked').length > 0) {
        $('.update_lead_date_wrapper').show();
        disableBackdateOption($('input[name*=common_lead_date]'));
    } else {
        $('.update_lead_date_wrapper').hide();
    }

}

export default massLeadDateUpdate