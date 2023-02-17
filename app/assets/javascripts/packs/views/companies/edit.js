const editAction = () => {

    $(document).ready(function () {
        let isInternational = $('input[name="company[is_international]"]:checked').val();
        if (isInternational === 'true') {
            $('#company_default_currency').prop("disabled", false);
            $('#company_default_currency_hidden').prop('disabled', true);
        }
        else{
            $('#company_default_currency').val('INR').trigger('change');
            $('#company_default_currency').prop("disabled", true);
            $('#company_default_currency_hidden').val('INR').prop('disabled', false);
        }
    });

    $('input[name="company[is_international]"]').on('change', function () {
        if ($(this).val() === 'true') {
            $('#company_default_currency').prop("disabled", false);
            $('#company_default_currency_hidden').prop('disabled', true);
        } else {
            $('#company_default_currency').val('INR').trigger('change');

            $('#company_default_currency').prop("disabled", true);
            $('#company_default_currency_hidden').val('INR').prop('disabled', false);
        }
    });
}
export default editAction
