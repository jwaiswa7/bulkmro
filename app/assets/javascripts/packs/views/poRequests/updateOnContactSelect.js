const updateOnContactSelect = () => {
    $('form').on('change', 'select[name*=contact_id]', function (e) {
        console.log('adwadw');
        onContactChange(this);
    }).find('select[name*=contact_id]').each(function (e) {
        var container = this
        if($(container).closest('.po-request-form').find('input[name*=contact_email]').val() == ""){
            onContactChange(this);
        }

    });
};
let onContactChange = (container) => {
    let optionSelected = $("option:selected", container);
    console.log(optionSelected);

    if (optionSelected.exists() && optionSelected.val() !== '') {
        var email = $(optionSelected).data('contact-email');
        var phone = $(optionSelected).data('contact-phone');
        if (email != "") {
            $(container).closest('.po-request-form').find('input[name*=contact_email]').val(email);
        }
        if (phone != "") {
            $(container).closest('.po-request-form').find('input[name*=contact_phone]').val(phone);
        }

    } else {
        $(container).closest('.po-request-form').find('input[name*=contact_email]').val("");
        $(container).closest('.po-request-form').find('input[name*=contact_phone]').val("");
    }


};

export default updateOnContactSelect