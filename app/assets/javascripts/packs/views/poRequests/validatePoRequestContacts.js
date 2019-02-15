const validatePoRequestContacts = () => {
    window.Parsley.addValidator('contact-email', {
        validateString: function (_value, contact, parsleyInstance) {
            var contactEmail = $(parsleyInstance.$element[0]).closest('div.po-request-form').find('select[name*=contact_id]').find(':selected').data("contact-email");
            console.log("phone", contactEmail);
            if (!contactEmail) {
                return false;
            }
        },
        messages: {
            en: 'In absence of email for a selected contact providing the contact email is mandatory'
        }
    });
    window.Parsley.addValidator('contact-phone', {
        validateString: function (_value, contact, parsleyInstance) {
            var contactPhone = $(parsleyInstance.$element[0]).closest('div.po-request-form').find('select[name*=contact_id]').find(':selected').data("contact-phone");
            console.log("phone", contactPhone, $(parsleyInstance.$element[0]).closest('div.po-request-form').find('select[name*=contact_id]').find(':selected').data("contact-phone"));
            if(!contactPhone) {
                return false
            }
        },
        messages: {
            en: 'In absence of phone(mobile/telephone) for a selected contact providing the contact phone is mandatory'
        }
    });
};

export default validatePoRequestContacts