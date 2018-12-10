const chooseCompany = () => {
    $('#redirect-login').click(function () {
        window.location.href = "/customers/dashboard?session_company_id=" + $('#choose-company').val();
    });

    $('#choose-company').select2();
};

export default chooseCompany