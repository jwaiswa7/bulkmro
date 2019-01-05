const index = () => {
    $('.add_to_inquiry_wrapper').hide();
    toggleCheckboxes();

    $('#add_to_inquiry').click((event) => {
        addToInquiry();
    });

};

let toggleCheckboxes = () => {
    $('#all_activities').prop("checked", false);

    $('#all_activities').change((event) => {
        var $element = $(event.target)
        if ($element.is(':checked')) {
            $('input[type=checkbox][name="activities[]"]').each((index, element) => {
                //$(element).attr('checked', 'checked')
                $(element).prop("checked", true);
                $('.add_to_inquiry_wrapper').show();
            });
        } else {
            $('input[type=checkbox][name="activities[]"]').each((index, element) => {
                //$(element).removeAttr('checked')
                $(element).prop("checked", false);
                $('.add_to_inquiry_wrapper').hide();
            });
        }
    });

    $('table').on('change', 'input[type=checkbox][name="activities[]"]', (event) => {
        showOrHideActions();
    })
}

let addToInquiry = () => {
    let activities = [];
    $('input[type=checkbox][name="activities[]"]:checked').each((index, element) => {
        activities.push($(element).val());
    });

    var inquiry = $('select[name*=inquiry]').val()
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

    $('input[type=checkbox][name="activities[]"]').each((index, element) => {
        if ($(element).is(':checked')) {
            hide = false;
        }
    });
    if (hide) {

        $('.add_to_inquiry_wrapper').hide();
    } else {
        $('.add_to_inquiry_wrapper').show();
    }


}

export default index