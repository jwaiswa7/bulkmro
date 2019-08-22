// to set the status filter upon selected status

const bindStatusChange = function () {
    $('[name="ar_invoice_request[cancellation_reason]"]').unbind().bind('change', function(){
        let val = $(this).val()
        if(val == 'Others'){
            $(".ar_invoice_other_cancellation_reason").removeClass('d-none')
            $(".ar_invoice_other_cancellation_reason").find('input').prop('required',true)
        }
        else{
            $(".ar_invoice_other_cancellation_reason").addClass('d-none')
            $(".ar_invoice_other_cancellation_reason").find('input').prop('required',false)
        }
    })

    $('[name="ar_invoice_request[rejection_reason]"]').unbind().bind('change', function(){
        let val = $(this).val()
        if(val == 'Rejected: Others'){
            $(".ar_invoice_request_other_rejection_reason").removeClass('d-none')
            $(".ar_invoice_request_other_rejection_reason").find('input').prop('required',true)

        }
        else{
            $(".ar_invoice_request_other_rejection_reason").addClass('d-none')
            $(".ar_invoice_request_other_rejection_reason").find('input').prop('required',false)
        }
    })


    $('[name="ar_invoice_request[status]"]').unbind().bind('change', function(){
        let val = $(this).val()
        $(".ar_invoice_request_cancellation_reason, .ar_invoice_request_rejection_reason,.ar_invoice_request_other_rejection_reason,.ar_invoice_other_cancellation_reason ").addClass('d-none')
        $(".ar_invoice_request_cancellation_reason, .ar_invoice_request_rejection_reason,.ar_invoice_request_other_rejection_reason,.ar_invoice_other_cancellation_reason ").find('input').prop('required',false)

        // for hide and show other rejection reson while selecting grpo rejection reason

        switch(val) {
            case 'AR Invoice Request Rejected':
                onStatusChange('ar_invoice_request_rejection_reason')
                break;
            case 'Cancelled AR Invoice':
                onStatusChange('ar_invoice_request_cancellation_reason')
                break;
            default:
        }
    })
};
export default bindStatusChange


let onStatusChange = (selector) => {
    console.log(selector)
    $("."+selector).removeClass('d-none');
    $("."+selector).find('select').prop('required',true);
    $("."+selector).find('input').prop('required',true);
}

