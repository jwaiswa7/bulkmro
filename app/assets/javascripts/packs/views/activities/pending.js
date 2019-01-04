const pending = () => {

    $('#all_activities').change((event) => {
        var $element = $(event.target)
        if ($element.is(':checked')) {
            $('input[type=checkbox][name="activities[]"]').each((index, element) => {
                $(element).attr('checked', 'checked')
            });
        } else {
            $('input[type=checkbox][name="activities[]"]').each((index, element) => {
                $(element).removeAttr('checked')
            });
        }


    });

    $('#approve_selected').click((event) => {
        let activities = []
        $('input[type=checkbox][name="activities[]"]:checked').each((index, element) => {
            activities.push($(element).val());
        });
        if (activities.length > 0) {
            $.ajax({
                url: Routes.approve_selected_overseers_activities_path(),
                type: "POST",
                data: JSON.stringify({activities: activities.join(',')}),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    console.log(response)
                }
            })
        }


        console.log(activities);
    })

};

export default pending