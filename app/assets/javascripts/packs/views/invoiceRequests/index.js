import updateSummaryBox from "../common/updateSummaryBox";

const index = () => {
    updateSummaryBox()

    $('.datatable').on('click','.cancel-invoice',function () {
        if( confirm('Do you want to cancel invoice request') ) {
            var id = $(this).data('invoice-request-id')
            var status = $('.cancellation-form-modal').data('status')
            var $this = $(this)
            $(this).addClass('disabled')
            $.ajax({
                data: {},
                url: "/overseers/invoice_requests/" + id + "/render_cancellation_form?status=" + status,
                success: function (data) {
                    $('.cancellation-form-modal').empty()
                    $('.cancellation-form-modal').append(data)
                    $('#cancelInvoice').modal('show')
                    modalSubmit()
                    $('#cancelInvoice').on('hidden.bs.modal', function () {
                        $this.removeClass('disabled')
                    })
                },
                complete: function complete() {
                }
            })
        }
    })

    $('.datatable').on('click', '.comment-invoice-request', function (e) {
        var id = $(this).data('invoice-request-id')
        var $this = $(this)
        $(this).addClass('disabled')
        $.ajax({
            data: {},
            url: "/overseers/invoice_requests/" + id + "/render_comment_form?",
            success: function (data) {
                $('.cancellation-form-modal').empty()
                $('.cancellation-form-modal').append(data)
                $('#addComment').modal('show')
                modalSubmit()
                $('#addComment').on('hidden.bs.modal', function () {
                    $this.removeClass('disabled')
                })
            },
            complete: function complete() {
            }
        })


    })

};

let modalSubmit = () => {
    $("#cancelInvoice,#addComment").on('click', '.confirm-cancel', function (event) {
        var formSelector = "#" + $(this).closest('form').attr('id'),
            datastring = $(formSelector).serialize();
        $.ajax({
            type: "PATCH",
            url: $(formSelector).attr('action'),
            data: datastring,
            dataType: "json",
            success: function success(data) {
                $('#cancelInvoice').modal('hide');
                window.location.reload()
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