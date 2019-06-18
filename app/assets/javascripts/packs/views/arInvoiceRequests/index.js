import updateSummaryBox from "../common/updateSummaryBox";

const index = () => {
    updateSummaryBox()

    $('.datatable').on('click','.cancel-ar-invoice, .reject-ar-invoice',function () {
        var status = $(this).attr('title')
        if( confirm('Do you want to '+ status.toLocaleLowerCase() +' the AR invoice request') ) {
            var id = $(this).data('invoice-request-id')
            var $this = $(this)
            $(this).addClass('disabled')
            $.ajax({
                data: {},
                url: "/overseers/ar_invoice_requests/" + id + "/render_cancellation_form?status=" + status,
                success: function (data) {
                    $('.cancellation-form-modal').empty()
                    $('.cancellation-form-modal').append(data)
                    $('#cancelInvoice').modal('show')
                    modalSubmit()
                    $('#cancelInvoice').on('hidden.bs.modal', function () {
                        $this.removeClass('disabled')
                    })
                    if(status == 'Cancel'){
                        $('[name="ar_invoice_request[cancellation_reason]"]').unbind().bind('change', function(){
                            let val = $(this).val()
                            if(val == 'Others'){
                                $(".ar_invoice_request_other_cancellation_reason").removeClass('d-none')
                                $(".ar_invoice_request_other_cancellation_reason").find('input').prop('required',true)
                            }
                            else{
                                $(".ar_invoice_request_other_cancellation_reason").addClass('d-none')
                                $(".ar_invoice_request_other_cancellation_reason").find('input').prop('required',false)
                            }
                        })
                    }
                    else if( status == 'Reject'){
                        $('[name="ar_invoice_request_request[rejection_reason]"]').unbind().bind('change', function(){
                            let val = $(this).val()
                            if(val == 'Rejected: Others'){
                                $(".ar_invoice_request_other_rejection_reason").removeClass('d-none')
                                $(".ar_invoice_request_other_rejection_reason").find('input').prop('required',true)

                            }
                            else{
                                $(".ar_invoice_other_rejection_reason").addClass('d-none')
                                $(".ar_invoice_other_rejection_reason").find('input').prop('required',false)
                            }
                        })
                    }
                },
                complete: function complete() {
                }
            })
        }
    })
};

let modalSubmit = () => {
    $("#cancelInvoice").on('click', '.confirm-cancel', function (event) {
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