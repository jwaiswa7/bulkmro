main = {
    init: function () {
        main.initSelects();
        main.initDynamicForms();
    },

    // Converts select to select2
    initSelects: function() {
        $('select:not(.ajax)').select2();

        $('select.ajax').each(function(k, v) {
            $(this).select2({
                theme: "bootstrap",
                ajax: {
                    url: $(this).attr('data-source'),
                    dataType: 'json',
                    delay: 100,
                }
            });
        });
    },

    // Handles dynamic additions of fields to nested forms
    initDynamicForms: function() {
        $('body')
            .on("fields_added.nested_form_fields", function(e, param) {
                main.initSelects();
            })
            .on("fields_removed.nested_form_fields", function(e, param) {
                main.initSelects();
            });
    },

};