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
                console.log ('jjjjjjj')

            },
            error: function(error) {
                if (error.responseJSON.error)
                    $(formSelector).find('.error').empty().html("<div class='p-1'>"+ error.responseJSON.error+ "</div>")
            }
        });
        event.preventDefault();

    });
};

export default addPacking
