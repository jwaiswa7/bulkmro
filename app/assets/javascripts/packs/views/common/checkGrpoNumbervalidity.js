
const grpoNumbervalidator = function () {
    $(".grpo-number-input").on('input',function (e) {
        let current_input=$(this).val();

        if(!current_input.startsWith('5')) {
            $(this).css("border", "2px solid rgb(255,0,0)");
            $(this).attr('data-toggle','tooltip');
            $(this).attr('data-original-title','Number should start with 5');
            $(this).parent().next().attr('disabled',true);
        }
        else{
            $(this).attr('data-original-title','');
            $(this).css("border", "2px solid #eceef2");
            $(this).parent().next().prop('disabled',false);
        }
    });
}

export default grpoNumbervalidator;