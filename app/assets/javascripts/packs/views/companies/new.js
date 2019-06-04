const newAction = () => {
        $('input[name=account]').on('click', function() {
            var inputValue = $(this).attr("value");
            var targetBox = $("." + inputValue);
            $(".box").not(targetBox).hide();
            $(targetBox).show();
        });

        $(document).ready(function() {
            $('input[name=account]:first').trigger('click');
        });
}
export default newAction
