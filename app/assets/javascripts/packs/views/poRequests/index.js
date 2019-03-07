const index = () => {

    $('.datatable').on('click', '.cancel-po_request', function () {
        if (confirm('Do you want to cancel the Po Request?')) {
            var id = $(this).data('po-request-id')
            var status = $('.cancellation-form-modal').data('status')
            var $this = $(this)
            $(this).addClass('disabled')
            $.ajax({
                data: {},
                url: "/overseers/po_requests/" + id + "/render_cancellation_form?status=" + status,
                success: function (data) {
                    $('.cancellation-form-modal').empty()
                    $('.cancellation-form-modal').append(data)
                    $('#cancelporequest').modal('show')
                    modalSubmit()
                    $('#cancelporequest').on('hidden.bs.modal', function () {
                        $this.removeClass('disabled')
                    })
                },
                complete: function complete() {
                }
            })
        }

    })
};

let modalSubmit = () => {
    $("#cancelporequest").on('click', '.confirm-cancel', function (event) {
        var formSelector = "#" + $(this).closest('form').attr('id'),
            datastring = $(formSelector).serialize();
        $.ajax({
            type: "PATCH",
            url: $(formSelector).attr('action'),
            data: datastring,
            dataType: "json",
            success: function success(data) {
                $('#cancelporequest').modal('hide');
                if (data.success == 0) {
                    alert(data.message);
                } else {
                    window.location.reload();
                }
            },
            error: function error(_error) {
                if (_error.responseJSON && _error.responseJSON.error && _error.responseJSON.error.base)
                    $(formSelector).find('.error').empty().html("<div class='p-1'>" + _error.responseJSON.error.base + "</div>");
            }
        });
        event.preventDefault();
    });
}

export default index