// to set the status filter upon selected status

const exportFilteredRecords = function (export_url, successMessage, failedMessage = 'Email cannot be delivered. Please click the export all button') {

    // To show/hide Filtered records button
    $('.datatable').on('filters:change', function () {
        $('#export_filtered_records').show();
    });

    $('.filter-list-input').on('keyup', function () {
        (window.hasher.getHashString() != "" || $(this).val() != '') ? $('#export_filtered_records').show() : $('#export_filtered_records').hide();
    });

    $('#export_filtered_records').click((event) => {
        let element = $(event.target);
        $(element).find('i').removeClass('fal fa-envelope').addClass('fas fa-circle-notch fa-spin');
        element.prop('disabled', true);
        let dataTable = $('.datatable').dataTable();
        let data = dataTable.api().ajax.params();
        event.preventDefault();
        $.ajax({
            url: export_url,
            type: "GET",
            data: data,
            error: function () {
                element.prop('disabled', false);
                $.notify({
                    message: failedMessage
                }, {
                    type: 'danger'
                }, {delay: 5000});
                $(element).find('i').removeClass('fas fa-circle-notch fa-spin').addClass('fal fa-envelope')
            },
            success: function () {
                element.prop('disabled', false);
                $.notify({
                    message: successMessage
                }, {
                    type: 'success'
                }, {delay: 5000});
                $(element).find('i').removeClass('fas fa-circle-notch fa-spin').addClass('fal fa-envelope')
            }
        });
    });
};

export default exportFilteredRecords