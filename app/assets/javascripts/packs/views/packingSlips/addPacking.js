import hideRemoveBtnInRows from "../common/hideRemoveBtnInRows"

const addPacking = () => {
    hideRemoveBtnInRows();
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
