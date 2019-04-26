
const newAction = () => {
    $('[name="ar_invoice[status]"]').unbind().bind('change', function(){
        let val = $(this).val()
        $(".ar_invoice_cancellation_reason, .ar_invoice_rejection_reason,.ar_invoice_other_rejection_reason,.ar_invoice_other_cancellation_reason ").addClass('d-none')
        $(".ar_invoice_cancellation_reason, .ar_invoice_rejection_reason,.ar_invoice_other_rejection_reason,.ar_invoice_other_cancellation_reason ").find('input').prop('required',false)


        // for hide and show other rejection reson while selecting grpo rejection reason

        switch(val) {
            case 'AR Invoice Request Rejected':
                onStatusChange('ar_invoice_rejection_reason')
                break;
            case 'Cancelled AR Invoice':
                onStatusChange('ar_invoice_cancellation_reason')
                break;
            default:
        }
    })


    $('[name="ar_invoice[rejection_reason]"]').unbind().bind('change', function(){
        let val = $(this).val()
        if(val == 'Rejected: Others'){
            $(".ar_invoice_other_rejection_reason").removeClass('d-none')
            $(".ar_invoice_other_rejection_reason").removeClass('d-none')
        }
        else{
            $(".ar_invoice_other_rejection_reason").addClass('d-none')
        }
    })

    $('[name="ar_invoice[cancellation_reason]"]').unbind().bind('change', function(){
        let val = $(this).val()
        if(val == 'Others'){
            $(".ar_invoice_other_cancellation_reason").removeClass('d-none')
        }
        else{
            $(".ar_invoice_other_cancellation_reason").addClass('d-none')
        }
    })

    $('.confirm-cancel').click(function(event) {
        if( !confirm('Do you want to Cancel the GRPO') ){
            event.preventDefault();
        }

    });
};


let onStatusChange = (selector) => {
    console.log(selector)
    $("."+selector).removeClass('d-none');
    $("."+selector).find('select').prop('required',true);
    $("."+selector).find('input').prop('required',true);
}

export default newAction