const newAction = () => {
    $('form').on('change', 'select[name*=company_id]', function (e) {
        onCompanyChange(this);
    });
};

let onCompanyChange = (container) => {
    let optionSelected = $("option:selected", container);
    if (optionSelected.exists() && optionSelected.val() !== '') {
        $.getJSON
        (
            {
                url: Routes.fetch_company_account_overseers_contacts_path(),
                data: {company_id: optionSelected.val()},
                success: function (response) {
                    $('#contact_account').val(response.account_name);
                }
            }
        );
    }
};

export default newAction