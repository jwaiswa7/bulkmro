const dataTables = () => {
    preSetup();
    setup();
    ajax();
};

// Setup the filter field before all dataTables, if the filter attribute exists
let preSetup = () => {
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
};

// Initialize and setup all dataTables
let setup = () => {
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
            "pageLength": 50,
            pagingType: 'full_numbers',
            order: [[$(that).find('th').length - 1, 'desc']], // Sort on the last column
            columnDefs: [{
                "targets": 'no-sort',
                "orderable": false
            }, {
                "targets": 'numeric',
                "render": $.fn.dataTable.render.number(',', '.', 0)
            }],
            fnServerParams: function (data) {
                data['columns'].forEach(function (items, index) {
                    data['columns'][index]['name'] = $(that).find('th:eq(' + index + ')').data('name');
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
                    '<span class="sr-only">Loading...</span>',
                paginate: {
                    first: '<i class="fal fa-arrow-to-left"></i>',
                    previous: '<i class="fal fa-angle-left"></i>',
                    next: '<i class="fal fa-angle-right"></i>',
                    last: '<i class="fal fa-arrow-to-right"></i>'
                }
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
        // var url = $(this).data('ajax');
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
document.addEventListener("turbolinks:before-cache", function() {
    cleanUp();
});

export default dataTables