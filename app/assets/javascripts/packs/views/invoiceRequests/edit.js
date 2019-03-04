import openRatingModal from "../common/openRatingModal";

const edit = () => {
    openRatingModal()
    $('.add-review').on('click',function (e) {
        $('#multipleRatingForm').modal('toggle')
    })
    let form_original_data = $("form").serializeArray();
    
    $('[name="invoice_request[status]"]').unbind().bind('change', function(){
        let val = $(this).val()
        $(".invoice_request_grpo_rejection_reason, .invoice_request_grpo_other_rejection_reason, .invoice_request_grpo_cancellation_reason ").addClass('d-none')
        $(".invoice_request_ap_rejection_reason, .invoice_request_ap_other_rejection_reason, .invoice_request_ap_cancellation_reason ").addClass('d-none')
        if(val == 'GRPO Request Rejected' ){
            $(".invoice_request_grpo_rejection_reason").removeClass('d-none')
        }
        else if( val == 'AP Invoice Request Rejected'){
            $(".invoice_request_ap_rejection_reason").removeClass('d-none')
        }
        else if(val == 'Cancelled GRPO' || val == 'Cancelled AP Invoice'){
            $(this)
            $(".invoice_request_cancellation_reason").removeClass('d-none');
        }
        else{
        }
    })
    $('[name="invoice_request[grpo_rejection_reason]"]').unbind().bind('change', function(){
        let val = $(this).val()
        if(val == 'Others'){
            $(".invoice_request_grpo_other_rejection_reason").removeClass('d-none')
        }
        else{
            $(".invoice_request_grpo_other_rejection_reason").addClass('d-none')
        }
    })
    $('[name="invoice_request[ap_rejection_reason]"]').unbind().bind('change', function(){
        let val = $(this).val()
        if(val == 'Others'){
            $(".invoice_request_ap_rejection_reason").removeClass('d-none')
        }
        else{
            $(".invoice_request_ap_rejection_reason").addClass('d-none')
        }
    })

    $('.confirm-cancel').click(function(event) {
        if( !confirm('Do you want to Cancel the GRPO') ){
            event.preventDefault();
        }

    });

    $('.submit-form').unbind().bind('click', function (event) {
        let form_changed_data = $("form").serializeArray(),
          changed_status = form_changed_data.filter(x => x.name === "invoice_request[status]"),
          original_status = form_original_data.filter(x => x.name === "invoice_request[status]");
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

export default edit