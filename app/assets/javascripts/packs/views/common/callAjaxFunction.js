const callAjaxFunction = function(json){
    $(json.this).addClass('disabled')
    $.ajax({
        data: {},
        url: json.url,
        success: function (data) {
            $(this).addClass('disabled')
            $(json.className).empty()
            $(json.className).append(data)
            $(json.modalId).modal('show')
            modalSubmit(json.modalId, json.buttonClassName)
            $(json.modalId).on('hidden.bs.modal', function () {
                json.this.removeClass('disabled')
            })
        },
        error: function error(_error) {

        }

    })
};

const modalSubmit = (modalId, buttonClassName) => {
    $(modalId).on('click', buttonClassName, function (event) {
        var formSelector = "#" + $(this).closest('form').attr('id'),
            datastring = $(formSelector).serialize();

        $.ajax({
            type: "PATCH",
            url: $(formSelector).attr('action'),
            data: datastring,
            dataType: "json",
            success: function success(data) {
                $(modalId).modal('hide');
                if (data.success == 0) {
                    alert(data.message);
                } else {
                    window.location.reload();
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

}

export default callAjaxFunction