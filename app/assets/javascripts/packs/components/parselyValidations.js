// Parsely JS overrides for browser/bootstrap validations
const parselyValidations = () => {
    $.extend(window.Parsley.options, {
        errorClass: 'is-invalid',
        successClass: 'is-valid',
        errorsWrapper: '<div class="invalid-feedback"></div>',
        errorTemplate: '<span></span>',
        trigger: 'change',
        focus: 'none',
        errorsContainer: function (e) {
            let $errorWrapper = e.$element.siblings('.invalid-feedback');
            if ($errorWrapper.length) {
                return $errorWrapper;
            } else {
                if (e.$element.closest('.form-group').find('.invalid-feedback').exists())
                    return e.$element.closest('.form-group').find('.invalid-feedback');
                else
                    return e.$element.closest('.form-group').append('<div class="invalid-feedback"></div>');
            }
        }
    });

    window.Parsley.on('form:validated', function (form) {
        form.$element.addClass('was-validated');
    });

    window.Parsley.on('field:success', function (e) {
        if (!$(this.element).parent().find('div.valid-feedback').exists() && $(this.element).attr('data-parsely-no-valid-feedback') === undefined) {
            $(this.element).parent().append('<div class="valid-feedback">Looks good!</div>');
        }
    });

    window.Parsley.on('form:validate', function (form) {
        if (!form.isValid()) {
            for (let n = 0; n < form.fields.length; n++) {
                if (form.fields[n].validationResult !== true) {
                    $('html').animate({
                        scrollTop: $(form.fields[n].$element[0]).offset().top - $('.navbar.navbar-expand-lg').height() - 10
                    }, 'fast');
                    break;
                }
            }
        }
    });

    $("[data-parsley-validate]").parsley();
};

export default parselyValidations