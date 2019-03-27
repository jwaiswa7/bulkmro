import openRatingModal from "../common/openRatingModal";

const edit = () => {
    openRatingModal()
    $('.add-review').on('click',function (e) {
        $('#multipleRatingForm').modal('toggle')
    })
    
    // original form data when form loaded
    let form_original_data = $("form").serializeArray();

    // for hind and show (rejection/cancellation)reasons input

    $('[name="invoice_request[status]"]').unbind().bind('change', function(){
        let val = $(this).val()
        $(".invoice_request_grpo_rejection_reason, .invoice_request_grpo_other_rejection_reason, .invoice_request_grpo_cancellation_reason ").addClass('d-none')
        $(".invoice_request_grpo_rejection_reason, .invoice_request_grpo_other_rejection_reason, .invoice_request_grpo_cancellation_reason ").find('input').prop('required',false)
        $(".invoice_request_ap_rejection_reason, .invoice_request_ap_cancellation_reason ").addClass('d-none')
        $(".invoice_request_ap_rejection_reason, .invoice_request_ap_cancellation_reason ").find('input').prop('required',false)

        switch(val) {
            case 'GRPO Request Rejected':
                $(".invoice_request_grpo_rejection_reason").removeClass('d-none');
                $(".invoice_request_grpo_rejection_reason").find('input').prop('required',true);
                break;
            case 'AP Invoice Request Rejected':
                $(".invoice_request_ap_rejection_reason").removeClass('d-none');
                $(".invoice_request_ap_rejection_reason").find('input').prop('required',true);
                break;
            case 'Cancelled GRPO':
                $(".invoice_request_grpo_cancellation_reason").removeClass('d-none');
                $(".invoice_request_grpo_cancellation_reason").find('input').prop('required',true);
                break;
            case 'Cancelled AP Invoice':
                $(".invoice_request_ap_cancellation_reason").removeClass('d-none');
                $(".invoice_request_ap_cancellation_reason").find('input').prop('required',true);
                break;
            default:
        }

    })

    // for hide and show other rejection reson while selecting grpo rejection reason

    $('[name="invoice_request[grpo_rejection_reason]"]').unbind().bind('change', function(){
        let val = $(this).val()
        if(val == 'Others'){
            $(".invoice_request_grpo_other_rejection_reason").removeClass('d-none')
        }
        else{
            $(".invoice_request_grpo_other_rejection_reason").addClass('d-none')
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