import hideRemoveBtnInRows from "../common/hideRemoveBtnInRows"

const addPacking = () => {
    hideRemoveBtnInRows();
    $(".packing-form").attr("disabled", "disabled");
    $("#packing input[name*='box_number']").on('change',function () {
        $("input[name*='box_numbers']").val()
        $("input[name*='box_numbers']").attr("required", true);
        console.log($("input[name*='box_numbers']").val())
       let s = $("input[name*='box_numbers']").map(function() {
           if ($(this).val() != '') return $(this).val()
       }).get();

       if (s.length ==  $("input[name*='box_numbers']").length){

           $(".packing-form").attr("disabled", false);
       }
       else{

           $(".packing-form").attr("disabled", true);
       }
    })

    $("form").on('click','.packing-form',function(event){

        var formSelector = "#"+$(this).closest('form').attr('id')
        var datastring = $(formSelector).find("input").serialize()
        console.log(datastring)
        $.ajax({
            type: "POST",
            url: $(formSelector).attr('action'),
            data: datastring,
            dataType: "json",
            success: function(data) {
                if (data.hasOwnProperty("message") && data.message != null) {
                    alert(data.message);
                }
                else {
                    if (data.hasOwnProperty("url") && data.url != null) {
                        window.location = data.url
                    } else {
                        window.location.reload();
                    }
                }
            },
            error: function error(_error) {
                console.log($(formSelector))
                if (_error.responseJSON && _error.responseJSON.error && _error.responseJSON.error.base)
                    $(formSelector).find('.error').empty().html("<div class='p-1'>" + _error.responseJSON.error.base + "</div>");
                console.log(_error);
            }
        });
        event.preventDefault();

    });
};

export default addPacking
