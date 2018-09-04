main = {
    a: undefined,
    load: function () {
        main.initGoogleAnalytics();
        main.initFilefields();
        main.initSelects();
        main.initParselyValidations();
        main.initDynamicForms();
        main.dataTables.init();
        main.initEditSuppliers();

        var dataAttributes = $('body').data();
        var controller = main.camelize(dataAttributes.controller);
        var controllerAction = main.camelize(dataAttributes.controllerAction);

        if (controller in main && controllerAction in main[controller]) {
            main[controller][controllerAction]()
        }
    },
    camelize: function camelize(text) {
        var separator = arguments.length <= 1 || arguments[1] === undefined ? '_' : arguments[1];
        var words = text.split(separator);
        var camelized = [words[0]].concat(words.slice(1).map(function (word) {
            return '' + word.slice(0, 1).toUpperCase() + word.slice(1).toLowerCase();
        }));
        return camelized.join('');
    },

    imports: {
        manageFailedSkus: function() {
            var onRadioChange = function(radio) {
                var newProductForm = $(radio).closest('div.wrapper').find('div.nested');

                if (isNaN(radio.value)) {
                    newProductForm.find(':input:visible:not(:radio)').prop('disabled', false);
                } else {
                    newProductForm.find(':input:visible:not(:radio)').prop('disabled', true);
                }
            };

            $(':input:visible:radio:checked').each(function(e) {
                onRadioChange(this);
            });

            $('input[name*=approved_alternative_id]:radio').on('change', function(e) {
                onRadioChange(this);
            });
        },
        createFailedSkus: function() { main.imports.manageFailedSkus() }
    },

    beforeCache: function () {
        main.dataTables.cleanUp()
    },

    initGoogleAnalytics: function () {
        if (typeof ga === 'function') {
            ga('set', 'location', event.data.url);
            return ga('send', 'pageview');
        }
    },

    initFilefields: function () {
        $('.custom-file-input').on('change', function () {
            $(this).next('.custom-file-label').addClass("selected").html($(this).val().split('\\').slice(-1)[0]);
        })
    },

    // Converts select to select2
    initSelects: function () {
        $('.select2-single:not(.select2-ajax), .select2-multiple:not(.select2-ajax)').select2({
            theme: "bootstrap",
            containerCssClass: ':all:',
        }).on('change', function () {
            $(this).trigger('input');
        });

        $('select.select2-ajax').each(function (k, v) {
            $(this).select2({
                theme: "bootstrap",
                containerCssClass: ':all:',
                ajax: {
                    url: $(this).attr('data-source'),
                    dataType: 'json',
                    delay: 100
                }
            });
        }).on('change', function () {
            $(this).trigger('input');
        });
    },

    // TO DO - REMOVE?
    // Handles dynamic additions of fields to nested forms
    initDynamicForms: function () {
        $('body')
            .on("fields_added.nested_form_fields", function (e, param) {
                main.initSelects();
            })
            .on("fields_removed.nested_form_fields", function (e, param) {
                main.initSelects();
            });
    },

    // Bootstrap override default browser validation with Bootstrap's helper classes
    initParselyValidations: function () {
        $.extend(window.Parsley.options, {
            errorClass: 'is-invalid',
            successClass: 'is-valid',
            errorsWrapper: '<span></span>',
            errorTemplate: '<span></span>',
            trigger: 'change',
            errorsContainer: function (e) {
                $errorWrapper = e.$element.siblings('.invalid-feedback');
                if ($errorWrapper.length) {
                    return $errorWrapper;
                } else {
                    return e.$element.closest('.form-group').find('.invalid-feedback');
                }

            }

        });

        window.Parsley.on('form:validated', function (form) {
            // form.$element.addClass('was-validated');
        });

        window.Parsley.on('field:success', function (e) {
            if (!$(this.element).parent().find('div.valid-feedback').exists() && $(this.element).attr('data-parsely-no-valid-feedback') === undefined) {
                $(this.element).parent().append('<div class="valid-feedback">Looks good!</div>');
            }
        });

        $("[data-parsley-validate]").parsley();
    },

    initBootstrapValidations: function () {
        $(document).ready(function () {
            // Fetch all the forms we want to apply custom Bootstrap validation styles to
            var forms = document.getElementsByClassName('needs-validation');
            // Loop over them and prevent submission
            var validation = Array.prototype.filter.call(forms, function (form) {
                form.addEventListener('submit', function (event) {
                    if (form.checkValidity() === false) {
                        event.preventDefault();
                        event.stopPropagation();
                    }
                    form.classList.add('was-validated');
                }, false);
            });
        }, false);
    },

    // Initaialize Bootstrap tooltips
    initTooltips: function () {
        $('[data-toggle="tooltip"]').tooltip();
    },

    dataTables: {
        init: function () {
            main.dataTables.preInit();
            main.dataTables.setup();
            main.dataTables.ajax();
        },

        // Setup the filter field before all DataTables if the filter attribute exists
        preInit: function () {
            $(document).on('preInit.dt', function (e, settings) {
                if ($(e.target).data('has-search') == true) return;

                var api = new $.fn.dataTable.Api(settings);
                var $target = $(e.target);
                var searchText = $target.data('search');

                if (searchText) {
                    var $input = "<input type='search' class='form-control filter-list-input' placeholder='" + searchText + "'>";
                    $input = $($input);
                    $input.on('keyup', function (e) {
                        $('#' + $target.attr('id')).DataTable().search($(this).val()).draw();
                    });

                    var $wrapper = "<div class='input-group input-group-round'>" +
                        "<div class='input-group-prepend'>" +
                        "<span class='input-group-text'>" +
                        "<i class='material-icons'>filter_list</i>" +
                        "</span>" +
                        "</div>" +
                        "</div>";

                    var $filter = $($wrapper).append($input);

                    $filter.insertBefore($target);
                    $target.data('has-search', true);
                }
            });
        },

        setup: function () {
            $('.datatable').each(function () {
                if ($.fn.dataTable.isDataTable('#' + $(this).attr('id'))) return false;
                var isAjax = !!$(this).data('ajax');
                var that = this;

                $.fn.dataTable.ext.errMode = 'throw';
                $(this).DataTable({
                    conditionalPaging: true,
                    searchDelay: 350,
                    serverSide: isAjax,
                    processing: true,
                    stateSave: false,
                    dom: "" + //<'row'<'col-12'<'input-group'f>>> <'col-sm-12 col-md-6'l>
                        "<'row'<'col-sm-12'tr>>" +
                        "<'row'<'col-12  align-items-center text-center'i><'col-12 align-items-center text-center'p>>",
                    pagingType: 'full_numbers',
                    order: [[0, 'desc']],
                    columnDefs: [{
                        "targets": 'no-sort',
                        "orderable": false
                    }, {
                        "targets": 'numeric',
                        "render": $.fn.dataTable.render.number(',', '.', 0)
                    }],
                    fnServerParams: function (data) {
                        data['columns'].forEach(function (items, index) {
                            data['columns'][index]['name'] = $(that).find('th:eq(' + index + ')').text();
                        });
                    },
                    responsive: {
                        details: {
                            renderer: function (api, rowIdx, columns) {
                                var $data = $.map(columns, function (col, i) {
                                    return col.hidden ?
                                        '<li class="list-group-item" data-dt-row="' + col.rowIndex + '" data-dt-column="' + col.columnIndex + '">' +
                                        (col.title ? '<span><strong>' + col.title + '</strong><br>' : '')
                                        + col.data +
                                        '</span>' +
                                        '</li>' : '';
                                }).join('');

                                return $data ?
                                    $('<ul/>').addClass('list-group').append($data) :
                                    false;
                            }
                        }
                    },

                    language: {
                        processing: '<i class="fal fa-spinner-third fa-spin fa-3x fa-fw"></i>' +
                            '<span class="sr-only">Loajjding...</span>',
                        paginate: {
                            first: '<i class="fal fa-arrow-to-left"></i>',
                            previous: '<i class="fal fa-angle-left"></i>',
                            next: '<i class="fal fa-angle-right"></i>',
                            last: '<i class="fal fa-arrow-to-right"></i>'
                        }
                    }
                })
            });
        },

        ajax: function () {
            if (!$('.datatable[data-ajax]')) return false;

            $('.datatable[data-ajax]').each(function () {
                // Add blur to make sure that the table is not visible before data's loaded in
                $(this).addClass('blur');

                // Remove the blur state after the table has loaded in
                $(this).on('init.dt', function () {
                    $(this).removeClass('blur');
                });

                // Load data from the specified data attribute
                var url = $(this).data('ajax');
                $(this).ajax.url(url).load();
            });
        },

        cleanUp: function () {
            $('.datatable').each(function () {
                if ($.fn.dataTable.isDataTable('#' + $(this).attr('id'))) {
                    $(this).DataTable().destroy();
                }
            });
        }
    },
    initEditSuppliers: function () {
        $('form[action$=update_suppliers] select[name*=supplier_id]').change(function (e) {
            var optionSelected = $("option:selected", this);
            var select = $(this).closest('select');

            if (optionSelected.exists() && optionSelected.val() !== '' ) {
                $.getJSON({
                    url: Routes.best_prices_overseers_product_path(select.data('product-id')),
                    data: {
                        supplier_id: optionSelected.val()
                    },
                    success: function (response) {
                        select.closest('div.row').find('[name*=lowest_unit_cost_price]').val(response.lowest_unit_cost_price);
                        select.closest('div.row').find('[name*=latest_unit_cost_price]').val(response.latest_unit_cost_price);
                    }
                });
            }
        })
    }
};

$.fn.exists = function () {
    return jQuery(this).length > 0;
};
