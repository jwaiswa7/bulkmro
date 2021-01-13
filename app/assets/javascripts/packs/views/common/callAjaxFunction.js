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
            if($(json.commentClass).length) {
                $(json.buttonClassName).prop('disabled', true);
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
                if (data.success == 0) {
                	$(modalId).modal('hide');
                    alert(data.message);
                } else {
                    if (data.hasOwnProperty("url") && data.url != null) {
                    	if (data.notice != undefined) {
                    		$(formSelector).find('.success').empty().html("<div class='p-1'>" + data.notice + "</div>");
                    	}
                        setTimeout(function(){ $(modalId).modal('hide'); window.location = data.url }, 1500);
                    } else {
                    	$(modalId).modal('hide');
                        window.location.reload();
                    }
                }
            },
            error: function error(_error) {
                if (_error.responseJSON && _error.responseJSON.error && _error.responseJSON.error.base) {
                    $(formSelector).find('.error').empty().html("<div class='p-1'>" + _error.responseJSON.error.base + "</div>");
                }
                else
                {
                    $(formSelector).find('.error').empty().html("<div class='p-1'>" + _error.responseJSON.error + "</div>");
                }

            }
        });
        event.preventDefault();
    });
};

export default callAjaxFunction