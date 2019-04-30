
const newAccountsConfirmation = () => {
    $('.account-approval').prop('disabled', true);

    $('input[type=checkbox]').click(function (f) {
        checkCheckboxStatus();
        let target = f.currentTarget.id;
        if (f.currentTarget.checked == true) {
            $(".summary-list ."+ target).removeClass('fa-times').addClass('fa-check');
        } else if (f.currentTarget.checked == false) {
            $(".summary-list ."+ target).removeClass('fa-check').addClass('fa-times');
        }
    });

    $('.account-rejection').click(function () {
        $('input[type=checkbox]').removeAttr('required')
    });

    let y = () => {

    };

};

let checkCheckboxStatus = () => {
    if ($('.new_accounts_confirmation input[type="checkbox"]').not(':checked').length == 0) {
        $('.account-approval').prop('disabled', false);
        $('.account-rejection').click();
    }else{
        $('.account-approval').prop('disabled', true);
    }

    if ($('.new_accounts_confirmation input[type="checkbox"]').not(':checked').length == 1) {
        $('.account-rejection').click();
    }
};

export default newAccountsConfirmation