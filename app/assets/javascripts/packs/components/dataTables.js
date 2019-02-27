// Component Imports
import select2s from "./select2s";

const dataTables = () => {
    preSetup();
    setup();
    ajax();
};

// Setup the filter field before all dataTables, if the filter attribute exists
let preSetup = () => {
    // $.fn.DataTable.ext.pager.numbers_length = 4;
    $(document).on('preInit.dt', function (e, settings) {
        if ($(e.target).data('has-search') == true) return;

        let api = new $.fn.dataTable.Api(settings);
        let $target = $(e.target);
        let searchText = $target.data('search');

        if (searchText) {
            let $input = "<input type='search' class='form-control filter-list-input' placeholder='" + searchText + "'>";
            $input = $($input);
            $input.bindWithDelay('keyup', function (e) {
                $('#' + $target.attr('id')).DataTable().search($(this).val()).draw();
            }, 300);

            let $wrapper = "<div class='input-group input-group-round'>" +
                "<div class='input-group-prepend'>" +
                "<span class='input-group-text'>" +
                "<i class='material-icons'>filter_list</i>" +
                "</span>" +
                "</div>" +
                "</div>";

            let $filter = $($wrapper).append($input);

            $filter.insertBefore($target);
            $target.data('has-search', true);
        }
    });
};

// Initialize and setup all dataTables
let setup = () => {
    $('.datatable').each(function () {
        if ($.fn.dataTable.isDataTable('#' + $(this).attr('id'))) return false;
        let isAjax = !!$(this).data('ajax');
        let isFixedHeader = $(this).data('fixed-header') == "false" ? false : true;
        let that = this;

        $.fn.dataTable.ext.errMode = 'throw';

        $(this).DataTable({
            orderCellsTop: true,
            searchDelay: 1000,
            serverSide: isAjax,
            processing: true,
            stateSave: false,
            fixedHeader: {
                header: isFixedHeader,
                headerOffset: $('.navbar.navbar-expand-lg').height()
            },
            fnDrawCallback: function (oSettings) {
                if (oSettings._iDisplayLength > oSettings.fnRecordsDisplay()) {
                    $(oSettings.nTableWrapper).find('.dataTables_paginate').hide();
                } else {
                    $(oSettings.nTableWrapper).find('.dataTables_paginate').show();
                }
            },
            info: true,
            dom: "" + //<'row'<'col-12'<'input-group'f>>> <'col-sm-12 col-md-6'l>
                "<'row'<'col-sm-12'tr>>" +
                "<'row'<'col-12 align-items-center text-center'i><'col-12 align-items-center text-center'p>>",
            "pageLength": 20,
            pagingType: 'full_numbers',
            order: [[$(that).find('th').length - 1, 'desc']], // Sort on the last column
            columnDefs: [{
                "targets": 'no-sort',
                "orderable": false
            }, {
                "targets": 'numeric',
                "render": $.fn.dataTable.render.number(',', '.', 0)
            }, {
                "targets": 'text-right',
                "class": 'text-right'
            }],
            fnServerParams: function (data) {
                data['columns'].forEach(function (items, index) {
                    data['columns'][index]['name'] = $(that).find('th:eq(' + index + ')').data('name');
                });
            },
            responsive: {
                details: {
                    renderer: function (api, rowIdx, columns) {
                        let $data = $.map(columns, function (col, i) {
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
                    '<span class="sr-only">Loading...</span>',
                paginate: {
                    first: '<i class="fal fa-arrow-to-left"></i>',
                    previous: '<i class="fal fa-angle-left"></i>',
                    next: '<i class="fal fa-angle-right"></i>',
                    last: '<i class="fal fa-arrow-to-right"></i>'
                }
            },

            initComplete: function (settings, json) {
                let table = this;

                // Init filters
                let actionTd = $(table).find('thead tr:eq(1) td:eq(0)');
                let clear = $('<a href="#" class="btn btn-sm px-2 btn-danger" data-toggle="tooltip" title="Clear search and all enabled filters"><i class="fal fa-times"></i></a>');
                clear.on('click', function (e) {
                    $('[data-filter="ajax"] select').val("").trigger('change');
                    $('[data-filter="dropdown"] select').val("").trigger('change');
                    $('[data-filter="daterange"] input').val("").trigger('change');
                    $('.filter-list-input').val("").trigger('keyup');
                    e.preventDefault();
                });
                actionTd.append(clear);

                this.api().columns().every(function () {
                    let column = this;
                    let filter = $(table).find('thead tr:eq(1) td:eq(' + column.index() + ')').data('filter');
                    let td = $(table).find('thead tr:eq(1) td:eq(' + column.index() + ')');
                    let text = $(column.header()).text();
                    let selected = (filter == 'dropdown' || filter == 'ajax') ? window.hasher.getParam(text).split('|') : window.hasher.getParam(text);

                    if (filter && filter != false) {
                        let input = '';

                        if (filter == 'dropdown') {
                            input = $('<select class="select2-single form-control" data-placeholder="' + [text, ' ', 'Select'].join('') + '"><option value="" selected disabled></option></select>');
                            json.columnFilters[this.index()].forEach(function (f) {
                                let option = $('<option value="' + f.value + '">' + f.label + '</option>');
                                input.append(option);
                            });
                        } else if (filter == 'daterange') {
                            input = $('<input class="form-control" data-toggle="daterangepicker" placeholder="' + 'Pick a date range" />');
                            input.val(selected);
                        } else if (filter == 'ajax') {
                            let source = "";
                            json.columnFilters[this.index()].forEach(function (f) {
                                source = f.source;
                            });
                            input = $('<select class="form-control select2-ajax" data-source="' + source + '" data-placeholder="' + [text, ' ', 'Select'].join('') + '"></select>');
                        } else {
                            input = $('<input type="text" class="form-control" placeholder="' + [text, ' ', 'Filter'].join('') + '" />');
                            input.val(selected);
                        }

                        input.on('change', function () {
                            let val = $(this).val();
                            column.search(val).draw();

                            // Set URL Hash
                            if ($(input).is('select'))
                                val = val ? [$(this).find('option:selected').text(), "|", val].join('') : '';

                            window.hasher.setParam(text, val);
                        });

                        td.append(input);
                        select2s();

                        if (!selected) return;
                        if (filter == 'dropdown') {
                            console.log(selected[1]);
                            input.val(selected[1]);
                        } else if (filter == 'ajax') {
                            input.append(new Option(selected[0], selected[1], true, true));
                        } else {
                            console.log(selected);
                            input.val(selected);
                        }
                    }
                });

                // Reload Datatable
                if (window.hasher.getHashString()) this.DataTable().ajax.reload();
            }
        })
    });
};

// How to handle datatTables which have an ajax attribute defined
let ajax = () => {
    if (!$('.datatable[data-ajax]')) return false;

    $('.datatable[data-ajax]').each(function () {
        // Add blur to make sure that the table is not visible before data's loaded in
        $(this).addClass('blur');

        // Remove the blur state after the table has loaded in
        $(this).on('init.dt', function () {
            $(this).removeClass('blur');
        });

        // Load data from the specified data attribute
        // let url = $(this).data('ajax');
        // $(this).ajax.url(url).load();
    });
};

// Pump and dump all DataTable set resources
let cleanUp = () => {
    $('.datatable').each(function () {
        if ($.fn.dataTable.isDataTable('#' + $(this).attr('id'))) {
            $(this).DataTable().destroy();
        }
    });
};

// Turbolinks hook
document.addEventListener("turbolinks:before-cache", function () {
    cleanUp();
});

export default dataTables