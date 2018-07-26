main = {
    load: function () {
        main.initSelects();
        main.initBootstrapValidations();
        main.initDynamicForms();
        main.dataTables.init();
    },

    beforeCache: function() {
        main.dataTables.cleanUp()
    },

    // Converts select to select2
    initSelects: function() {
        $('.select2-single:not(.select2-ajax), .select2-multiple:not(.select2-ajax)').select2({
            theme: "bootstrap",
            containerCssClass: ':all:',
        });

        $('select.select2-ajax').each(function(k, v) {
            $(this).select2({
                theme: "bootstrap",
                containerCssClass: ':all:',
                ajax: {
                    url: $(this).attr('data-source'),
                    dataType: 'json',
                    delay: 100
                }
            });
        });
    },

    // TO DO - REMOVE?
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

    // Bootstrap override default browser validation with Bootstrap's helper classes
    initBootstrapValidations: function() {
        $(document).ready(function() {
            // Fetch all the forms we want to apply custom Bootstrap validation styles to
            var forms = document.getElementsByClassName('needs-validation');
            // Loop over them and prevent submission
            var validation = Array.prototype.filter.call(forms, function(form) {
                form.addEventListener('submit', function(event) {
                    if (form.checkValidity() === false) {
                        event.preventDefault();
                        event.stopPropagation();
                    }
                    form.classList.add('was-validated');
                }, false);
            });
        }, false);
    },

    dataTables: {
        init: function() {
            main.dataTables.preInit();
            main.dataTables.setup();
        },

        // Setup the filter field before all DataTables if the filter attribute exists
        preInit: function() {
            $(document).on('preInit.dt', function(e, settings) {
                if ($(e.target).data('has-search') == true) return;

                var api = new $.fn.dataTable.Api(settings);
                var $target = $(e.target);
                var searchText = $target.data('search');

                if (searchText) {
                    var $input = "<input type='search' class='form-control filter-list-input' placeholder='" + searchText +"'>";
                    $input = $($input);
                    $input.on('keyup', function(e){
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

        setup: function() {
            $('.datatable').each(function() {
                if ($.fn.dataTable.isDataTable('#' + $(this).attr('id'))) return false;

                $(this).DataTable({
                    stateSave: true,
                    dom: "" + //<'row'<'col-12'<'input-group'f>>> <'col-sm-12 col-md-6'l>
                    "<'row'<'col-sm-12'tr>>" +
                    "<'row'<'col-12  align-items-center text-center'i><'col-12 align-items-center text-center'p>>",
                    pagingType: 'full_numbers',
                    order: [[1, 'asc']],
                    columnDefs: [{
                        "targets"  : 'no-sort',
                        "orderable": false
                    }, {
                        "targets"  : 'numeric',
                        "render": $.fn.dataTable.render.number(',', '.', 0)
                    }],
                    responsive: {
                        details: {
                            renderer: function (api, rowIdx, columns) {
                                var $data = $.map( columns, function (col, i) {
                                    return col.hidden ?
                                        '<li class="list-group-item" data-dt-row="'+col.rowIndex+'" data-dt-column="'+col.columnIndex+'">'+
                                        (col.title ? '<span><strong>'+col.title+'</strong><br>' : '')
                                        +col.data+
                                        '</span>'+
                                        '</li>' : '';
                                } ).join('');

                                return $data ?
                                    $('<ul/>').addClass('list-group').append($data) :
                                    false;
                            }
                        }
                    },

                    language: {
                        paginate: {
                            first: '<i class="fal fa-arrow-to-left"></i>',
                            previous: '<i class="fal fa-angle-left"></i>',
                            next: '<i class="fal fa-angle-right"></i>',
                            last: '<i class="fal fa-arrow-to-right"></i>'
                        }
                    }
                });
            });
        },

        cleanUp: function() {
            $('.datatable').each(function() {
                if ($.fn.dataTable.isDataTable('#' + $(this).attr('id'))) {
                    $(this).DataTable().destroy();
                }
            });
        }
    }

};