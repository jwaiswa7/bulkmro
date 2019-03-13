import exportDaterange from '../common/exportDaterange'

const index = () => {
    $('.add_to_inquiry_wrapper').hide();
    toggleCheckboxes();

    $('#add_to_inquiry').click((event) => {
        addToInquiry();
    });
    exportDaterange();

    // To show/hide Filtered records button
    $('#export_filtered_records').hide();

    $('.datatable').on('filters:change', function () {
        $('#export_filtered_records').show();
    });

    $('#export_filtered_records').click((event) => {
        let element = $(event.target);
        let dataTable = $('.datatable').dataTable();
        let data = dataTable.api().ajax.params();
        event.preventDefault();
        setTimeout(60000),
        $.ajax({
            url: Routes.export_filtered_records_overseers_activities_path(),
            type: "GET",
            data: data,
            success: function () {
                $.notify({
                    message: 'Email sent with Filtered Activities!'
                }, {
                    type: 'info'
                }, {delay: 5000});
            }
        });
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
                showOrHideActions();
            });
        } else {
            $('input[type=checkbox][name="activities[]"]').each((index, element) => {
                //$(element).removeAttr('checked')
                $(element).prop("checked", false);
                showOrHideActions();
            });
        }
    });

    $('table').on('change', 'input[type=checkbox][name="activities[]"]', (event) => {
        showOrHideActions();
    })
};

let addToInquiry = () => {
    let activities = [];
    $('input[type=checkbox][name="activities[]"]:checked').each((index, element) => {
        activities.push($(element).val());
    });

    var inquiry = $('select[name*=inquiry]').val();
    if (inquiry == '') {
        alert("Please Choose an Inquiry to Assign");
        $('#inquiry_select').select2('open');
    }

    if (activities.length > 0 && inquiry != '') {

        var data = JSON.stringify({activities: activities, inquiry: inquiry});
        $.ajax({
            url: Routes.add_to_inquiry_overseers_activities_path(),
            type: "POST",
            data: data,
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function () {
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

    if ($('input[type=checkbox][name="activities[]"]:checked').length > 0) {
        $('.add_to_inquiry_wrapper').show();
    } else {
        $('.add_to_inquiry_wrapper').hide();
    }

};

export default index