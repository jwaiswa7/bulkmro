
const newAction = () => {
    console.log('9999999999999999999')
    // original form data when form loaded
    let form_original_data = $("form").serializeArray();


    $('[name="ar_invoice_request[status]"]').unbind().bind('change', function(){
        let val = $(this).val()
        console.log(val)
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

    $('.confirm-cancel').click(function(event) {
        if( !confirm('Do you want to Cancel the GRPO') ){
            event.preventDefault();
        }

    });

    // on form submit if invoice request want to cancel then open pop_up and confirm again

    $('.submit-form').unbind().bind('click', function (event) {
        let form_changed_data = $("form").serializeArray(),
            changed_status = form_changed_data.filter(x => x.name === "ar_invoice_request[status]"),
            original_status = form_original_data.filter(x => x.name === "ar_invoice_request[status]");
        console.log('changed_status')
        console.log(changed_status)
        if(changed_status){
            let is_cancel_status = changed_status[0]['value'].toLowerCase().indexOf('cancel') != -1
            if(is_cancel_status && original_status && (changed_status[0]['value'] != original_status[0]['value'])){
                if (changed_status[0]['value'] == 'Cancelled AP Invoice'){
                    if( !confirm('Do you want to Cancel the AP Invoice ?') ){
                        event.preventDefault();
                    }
                }
                else{
                    if( !confirm('Do you want to Cancel the GRPO?') ){
                        event.preventDefault();
                    }
                }
            }
        }


    })


};


let onStatusChange = (selector) => {
    console.log(selector)
    $("."+selector).removeClass('d-none');
    $("."+selector).find('select').prop('required',true);
    $("."+selector).find('input').prop('required',true);
}



export default newAction