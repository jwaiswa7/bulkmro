
const newAccountsConfirmation = () => {
    $('.account-approval').prop('disabled', true);

    $('.new_accounts_confirmation input[type=checkbox]').click(function (f) {
        checkCheckboxStatus();
        let target = f.currentTarget.id;
        if (f.currentTarget.checked == true) {
            $(".summary-list ."+ target).removeClass('fa-times').addClass('fa-check');
        } else if (f.currentTarget.checked == false) {
            $(".summary-list ."+ target).removeClass('fa-check').addClass('fa-times');
        }
    });

    $('.account-rejection').click(function () {
        $('input[type=checkbox]').removeAttr('required');
    });
};

let checkCheckboxStatus = () => {
    if ($('.new_accounts_confirmation input[type="checkbox"]').not(':checked').length == 0) {
        $('.account-approval').prop('disabled', false);
        $('#sales_order_custom_fields_message').removeAttr('required')
    }else{
        $('.account-approval').prop('disabled', true);
        $('#sales_order_custom_fields_message').attr('required', 'required')
    }
};

export default newAccountsConfirmation