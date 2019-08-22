const cancelStatusConfirmation = function () {

    // original form data when form loaded
    let form_original_data = $("form").serializeArray();


    $('.confirm-cancel').click(function(event) {
        if( !confirm('Do you want to Cancel the GRPO') ){
            event.preventDefault();
        }

    });

    $('.submit-form').unbind().bind('click', function (event) {
        let form_changed_data = $("form").serializeArray(),
            changed_status = form_changed_data.filter(x => x.name === "ar_invoice_request[status]"),
            original_status = form_original_data.filter(x => x.name === "ar_invoice_request[status]");
        if(changed_status){
            let is_cancel_status = changed_status[0].value.toLowerCase().indexOf('cancel') != -1
            if(is_cancel_status && original_status && (changed_status[0].value != original_status[0].value)){
                if (changed_status[0].value == 'Cancelled AP Invoice'){
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

    // on form submit if invoice request want to cancel then open pop_up and confirm again
    $('.delete_row').on('click', function (event) {
        $(event.target).closest('.simple-row').find('input[type="text"]').remove();
    })
}
export default cancelStatusConfirmation