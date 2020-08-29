const callAjaxFunction = function(json){
    $(json.this).addClass('disabled');
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
            $(this).addClass('disabled');
            $(json.className).empty();
            $(json.className).append(data);
            $(json.modalId).modal('show');
            $('#submitPO').prop('disabled', true);
            if($(json.commentClass).length) {
                $(json.commentClass).keyup(function () {
                    if ($(this).val() == '' || $(this).val() == undefined) {
                        $(json.buttonClassName).prop('disabled', true);
                    } else {
                        $(json.buttonClassName).prop('disabled', false);
                    }
                });
            }
            modalSubmit(json.modalId, json.buttonClassName);
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
        var formSelector = "#" + $(this).closest('form').attr('id'), datastring = $(formSelector).serialize();
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
                    if (data.hasOwnProperty("url") && data.url != null) {
                        window.location = data.url
                    } else {
                        window.location.reload();
                    }
                }
            },
            error: function error(_error) {
                if (_error.responseJSON && _error.responseJSON.error)
                    $(formSelector).find('.error').empty().html("<div class='p-1'>" + _error.responseJSON.error + "</div>");
            }
        });
        event.preventDefault();
    });
};

export default callAjaxFunction