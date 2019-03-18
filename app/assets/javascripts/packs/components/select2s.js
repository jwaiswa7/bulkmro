// Converts select to select2
const select2s = () => {
    // Select2 Single Dropdown (not AJAX)
    $('.select2-single:not(.select2-ajax)').each(function() {
        $(this).select2({
            theme: "bootstrap",
            containerCssClass: ':all:',
            dropdownAutoWidth: true,
            width: 'auto',
            allowClear: !($(this).prop('required') || $(this).hasClass('required')),
            placeholder: ''
        }).on('change', function () {
            $(this).trigger('input');
        });
    });

    // Select2 Multiple Dropdown (not AJAX)
    $('.select2-multiple:not(.select2-ajax)').each(function () {
        let isTags = $(this).hasClass('select2-tags');

        $(this).select2({
            theme: "bootstrap",
            containerCssClass: ':all:',
            tags: isTags,
            allowClear: !($(this).prop('required') || $(this).hasClass('required')),
            placeholder: ''
        }).on('change', function () {
            $(this).trigger('input');
        });
    });

    // Select2 Ajax
    $('select.select2-ajax').each(function (k, v) {
        $(this).select2({
            theme: "bootstrap",
            containerCssClass: ':all:',
            dropdownAutoWidth: true,
            width: 'auto',
            allowClear: !($(this).prop('required') || $(this).hasClass('required')),
            placeholder: '',
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
};

export default select2s