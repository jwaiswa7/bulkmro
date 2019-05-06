const index = () => {

    addComment()

    $('.cancellation-form-modal').on('change', 'select[name*=rejection_reason]', function (e) {
        if ($(e.target).val() == "Others") {
            $('#other-rejection-reason').removeClass('disabled');
            $('#other-rejection-reason').attr("disabled", false);
            $('#other-rejection-reason').attr("required", true);
        } else {
            $('#other-rejection-reason').attr("disabled", true);
            $('#other-rejection-reason').find('textarea').val('').attr("required", false);
        }
    });

    $('.datatable').on('click', '.cancel-po_request', function (e) {
        if (confirm('Do you want to '+ $(this).attr('title').toLowerCase() +' the PO Request?')) {
            var id = $(this).data('po-request-id')
            var $this = $(this)
            var title = $(this).attr('title')

            $(this).addClass('disabled')
            $.ajax({
                data: {},
                url: "/overseers/po_requests/" + id + "/render_cancellation_form?purpose=" + title,
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

let addComment = () => {
    $(".bulk-update-form").on('click', '.bulk-update', function (event) {
        var formSelector = $(".bulk-update-form"),
            datastring = $(formSelector).serialize();
        $.ajax({
            data: {},
            url: "/overseers/po_requests/" + id + "/add_comment",
            success: function (data) {
                $('.bulk-update-form').empty()
                $('.bulk-update-form').append(data)
                $('#addComment').modal('show')
                modalSubmit()
                $('#addComment').on('hidden.bs.modal', function () {
                    $this.removeClass('disabled')
                })
            },
            complete: function complete() {
            }
        });
        event.preventDefault();
    });
}

export default index