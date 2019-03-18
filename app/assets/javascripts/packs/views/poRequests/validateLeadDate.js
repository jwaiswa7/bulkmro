const validateLeadDate = () => {
    window.Parsley.addValidator('customercommitteddate', {
        validateString: function (_value, c, parsleyInstance) {
            if(new Date(_value) > new Date(c)){
                return false;
            }
        },
        messages: {
            en: 'Lead Date cannot be greater than the customer committed date in inquiry'
        }
    });
};

export default validateLeadDate