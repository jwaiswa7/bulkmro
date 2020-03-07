// Converts select to select2
const select2s = () => {
    // Select2 Single Dropdown (not AJAX)
    $('.select2-single:not(.select2-ajax)').each(function() {
        let placeholder = $(this).attr('placeholder') ? $(this).attr('placeholder') : $(this).data('placeholder') ? $(this).data('placeholder') : $(this).find('option').first().val() == "" ? $(this).find('option').first().text() : '';

        $(this).select2({
            theme: "bootstrap",
            containerCssClass: ':all:',
            dropdownAutoWidth: true,
            width: 'auto',
            allowClear: !($(this).prop('required') || $(this).hasClass('required')),
            placeholder: placeholder
        }).on('change', function () {
            $(this).trigger('input');
        });
    });

    // Select2 Multiple Dropdown (not AJAX)
    $('.select2-multiple:not(.select2-ajax)').each(function () {
        let isTags = $(this).hasClass('select2-tags');
        let placeholder = $(this).attr('placeholder') ? $(this).attr('placeholder') : $(this).data('placeholder') ? $(this).data('placeholder') : $(this).find('option').first().val() == "" ? $(this).find('option').first().text() : '';

        $(this).select2({
            theme: "bootstrap",
            containerCssClass: ':all:',
            tags: isTags,
            allowClear: !($(this).prop('required') || $(this).hasClass('required')),
            placeholder: placeholder
        }).on('change', function () {
            $(this).trigger('input');
        });
    });

    // Select2 Ajax
    $('select.select2-ajax').each(function (k, v) {
        let placeholder = $(this).attr('placeholder') ? $(this).attr('placeholder') : $(this).data('placeholder') ? $(this).data('placeholder') : $(this).find('option').first().val() == "" ? $(this).find('option').first().text() : '';

        $(this).select2({
            theme: "bootstrap",
            containerCssClass: ':all:',
            dropdownAutoWidth: true,
            width: 'auto',
            allowClear: !($(this).prop('required') || $(this).hasClass('required')),
            placeholder: placeholder,
            ajax: {
                url: $(this).attr('data-source'),
                dataType: 'json',
                delay: 250
            },
            processResults: function (data, page) {
                return {results: data};
            },

        });
    }).on('change', function () {
        $(this).trigger('input');
    });
    // open select to field using tab
    $('form').on('focus', '.select2.select2-container', function (e) {
        if (e.originalEvent && $(this).find(".select2-selection--single").length > 0) {
            $(this).siblings('select:enabled').select2('open');
        }
    });
};

export default select2s