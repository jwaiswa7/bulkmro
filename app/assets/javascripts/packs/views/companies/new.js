const newAction = () => {
    $('input[name=account]').on('click', function () {
        var inputValue = $(this).attr("value");
        if ($(this).val() == "new") {
            $("#company_account_id").attr("required", false);
            $("#company_account_name").attr("required", true);
        }
        else if($(this).val() == "existing"){
            $("#company_account_name").attr("required", false);
            $("#company_account_id").attr("required", true);
        }
        var targetBox = $("." + inputValue);
        $(".box").not(targetBox).hide();
        $(targetBox).show();
    });

    $(document).ready(function () {
        $('input[name=account]:first').trigger('click');
    });
}
export default newAction
