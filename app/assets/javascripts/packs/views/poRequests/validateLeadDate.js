const validateLeadDate = () => {
    $('body').on('change', 'input[name*=lead_time]', function (e) {
        var leadTime = $(e.target).val();
        var customerCommittedDate = $(e.target).data('customer-committed-date');

        if (new Date(leadTime) > new Date(customerCommittedDate) && $('.late_lead_date_reason').val() == "") {
            $('.late_lead_date_reason').removeClass('d-none');
            $('.late_lead_date_reason').find('input').attr("required", true);
        } else {
            $('.late_lead_date_reason').addClass('d-none');
            $('.late_lead_date_reason').find('input').attr("required", false);
        }
    });
};

export default validateLeadDate