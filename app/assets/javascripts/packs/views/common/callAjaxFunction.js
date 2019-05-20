const callAjaxFunction = function (json) {
    $(json.this).addClass('disabled')
    var data;
    if (json.title != '') {
        data = {'title': json.title}
    } else {
        data = {}
    }
    $.ajax({
        data: data,
        url: json.url,
        type: 'GET',
        success: function (data) {
            $(this).addClass('disabled')
            $(json.className).empty()
            $(json.className).append(data)
            $(json.modalId).modal('show')
            commentSubmit(json.modalId, json.buttonClassName)
            $(json.modalId).on('hidden.bs.modal', function () {
                json.this.removeClass('disabled')
            })
        }
    })
};

const commentSubmit = (modalId, buttonClassName) => {
    $(modalId).on('click', buttonClassName, function (event) {

        var formSelector = ".modal #" + $(this).closest('form').attr('id'),
            datastring = $(formSelector).serialize();
        $.ajax({
            type: "PATCH",
            url: $(formSelector).attr('action'),
            data: datastring,
            dataType: "json",
            success: function success(data) {
                $(modalId).modal('hide');
                console.log(data)
                if (data.success == 0) {
                    alert(data.message);
                } else {
                    if (data.hasOwnProperty("url") && data.url != null) {
                        window.location = data.url
                    } else {
                        window.location.reload();
                    }
                }
            },
            error: function error(_error) {
                console.log(_error)
                if (_error.responseJSON && _error.responseJSON.error && _error.responseJSON.error.base)
                    $(formSelector).find('.error').empty().html("<div class='p-1'>" + _error.responseJSON.error.base + "</div>");
            }
        });
        event.preventDefault();
    });

}

export default callAjaxFunction