import openRatingModal from "../common/openRatingModal";

const edit = () => {
    openRatingModal()
    $('.add-review').on('click',function (e) {
        $('#multipleRatingForm').modal('toggle')
    })

    $('[name="invoice_request[status]"]').unbind().bind('change', function(){
        let val = $(this).val()
        if(val == 'GRPO Request Rejected' || val == 'AP Invoice Rejected'){
            $(".invoice_request_rejection_reason").removeClass('d-none')
        }
        else{
            $(".invoice_request_rejection_reason, .invoice_request_other_rejection_reason").addClass('d-none')
        }
    })
    $('[name="invoice_request[rejection_reason]"]').unbind().bind('change', function(){
        let val = $(this).val()
        if(val == 'Others'){
            $(".invoice_request_other_rejection_reason").removeClass('d-none')
        }
        else{
            $(".invoice_request_other_rejection_reason").addClass('d-none')
        }
    })

    $('.confirm-cancel').click(function(event) {
        if( !confirm('Do you want to Cancel the GRPO') ){
            event.preventDefault();
        }

    });

};

export default edit