const pending = () => {
    $('#approve_selected,#reject_selected').hide();
    toggleCheckboxes();
    $('#approve_selected').click((event) => {
        updateActivitiesApproval('approve');
    });
    $('#reject_selected').click((event) => {

        let message = 'Activity';
        if ($('input[type=checkbox][name="activities[]"]:checked').length > 1) {
            message = 'Activities';
        }
        if (confirm("Do you want to Reject " + $('input[type=checkbox][name="activities[]"]:checked').length + " " + message)) {
            updateActivitiesApproval('reject');
        }

    });

};

let toggleCheckboxes = () => {
    $('#all_activities').prop("checked", false);

    $('#all_activities').change((event) => {
        var $element = $(event.target);
        if ($element.is(':checked')) {
            $('input[type=checkbox][name="activities[]"]').each((index, element) => {
                //$(element).attr('checked', 'checked')
                $(element).prop("checked", true);
                $('#approve_selected,#reject_selected').show();
            });
        } else {
            $('input[type=checkbox][name="activities[]"]').each((index, element) => {
                //$(element).removeAttr('checked')
                $(element).prop("checked", false);
                $('#approve_selected,#reject_selected').hide();
            });
        }
    });

    $('table').on('change', 'input[type=checkbox][name="activities[]"]', (event) => {
        showOrHideActions();
    })
};

let updateActivitiesApproval = (action) => {
    let activities = [];
    $('input[type=checkbox][name="activities[]"]:checked').each((index, element) => {
        activities.push($(element).val());
    });

    let url = '';
    if (action == 'approve') {
        url = Routes.approve_selected_overseers_activities_path();
    } else {
        url = Routes.reject_selected_overseers_activities_path();
    }
    if (activities.length > 0 && url != '') {
        var data = JSON.stringify({activities: activities});
        $.ajax({
            url: url,
            type: "POST",
            data: data,
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (response) {
                var dataTable = $('.datatable').dataTable();
                dataTable.api().ajax.reload(null, false);
                $('#all_activities').removeAttr('checked');
                $('#all_activities').prop("checked", false);
            }
        });
    }
};


let showOrHideActions = () => {
    var hide = true;

    $('input[type=checkbox][name="activities[]"]').each((index, element) => {
        if ($(element).is(':checked')) {
            hide = false;
        }
    });
    if (hide) {
        $('#approve_selected,#reject_selected').hide();
    } else {
        $('#approve_selected,#reject_selected').show();
    }
};

export default pending