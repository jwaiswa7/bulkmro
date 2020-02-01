// Component Imports
import select2s from "./select2s";

const dataTables = () => {
    preSetup();
    setup();
    ajax();
    $('.datatable').DataTable().rowGroup().disable().draw();
    if (typeof $(".dataTable").data('ajax') !== 'undefined'){
        let data_ajax = $('.datatable').data('ajax');
        let report_name = data_ajax.split('/').pop();
        if (report_name == 'company_report') {
            $('.datatable').DataTable().rowGroup().enable().draw();
        }
    }
    $('.bmro-date-bag').on('change',function(){
        var currentVal = $(this).val();
        $('.date-item.hide').find('input').val(currentVal).trigger('change');
    })

    $('.export-toggle').click(function() {
        $('.export-toggle').parent().removeClass('show');
        $(this).parent().addClass('show',2000);
    })
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
            let $input = "<div class='bmro-search-table'>"+"<div class='bmro-input-search'>"+"<input type='search' class='bmro-form-input bmro-search-width filter-list-input' placeholder='" + searchText + "'>"+"</div>" +
                "</div>";
            $input = $($input);
            $input.bindWithDelay('keyup', function (e) {
                $('#' + $target.attr('id')).DataTable().search($(this).find("input").val()).draw();
            }, 300);
            let $wrapper =
                "<div class='fillter-wrapper bmro-input-edit'>" +
                "<div class='bmro-input-search bmro-arrow-parent'>" +
                " <input type='button' name='clear-btn' value='Reset' class='bmro-button bmro-set-size reset-table-filters'>" +
                "</div>" +
                "</div>";
            let $filter = $($input).append($wrapper);
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
        let allowSort = $(this).data('sort') ? $(this).data(sort) : true;
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
                headerOffset: $('.bmro-head-bg').outerHeight()
            },
            fnDrawCallback: function (oSettings) {
                let table = this;
                if (oSettings._iDisplayLength > oSettings.fnRecordsDisplay()) {
                    $(oSettings.nTableWrapper).find('.dataTables_paginate').hide();
                } else {
                    $(oSettings.nTableWrapper).find('.dataTables_paginate').show();
                }
                this.api().columns().every(function () {
                    let column = this;
                    let td = $(table).find('thead tr:eq(2) td:eq(' + column.index() + ')');
                    let columnData = column.data();
                    let value = columnData.sum();
                    let currencyFormatter = new Intl.NumberFormat('en-IN', {
                        style: 'currency',
                        currency: 'INR',
                        minimumFractionDigits: 2
                    });
                    if (value && value != "") {
                        if (td.hasClass('currency')){
                            td.empty().append(parseInt(value))
                        }
                        else if(td.hasClass('percentage')){
                            let percentValue = (value / columnData.length);
                            td.empty().append(parseInt(percentValue))
                        }
                        else if(td.hasClass('gross_margin_percentage_total')){
                            let assumed_margin = parseInt($('.gross_margin_assumed_value').html().replace(/,/g , ''));
                            let total_order_value = parseInt($('.total_sales_order_value').html().replace(/,/g , ''));
                            let total_gross_margin_percentage = (assumed_margin/total_order_value)*100;
                            td.empty().append(parseInt(total_gross_margin_percentage));
                        }
                        else if(td.hasClass('total_inquiries_won_percentage')){
                            let total_inquiries_count = parseInt($('.total_inquiries_count').html().replace(/,/g , ''));
                            let inquiries_won_percentage = (value/total_inquiries_count)*100;
                            td.empty().append(parseInt(inquiries_won_percentage));
                        }
                        else if(td.hasClass('actual_margin_percentage')){
                            let total_gross_margin_actual = parseInt($('.total_gross_margin_actual').html().replace(/,/g , ''));
                            let total_invoice_value = parseInt($('.total_invoice_value').html().replace(/,/g , ''));
                            let total_actual_margin_percentage = (total_gross_margin_actual/total_invoice_value)*100;
                            td.empty().append(parseInt(total_actual_margin_percentage));
                        }
                        else if(td.hasClass('no-data')){
                            td.empty()
                        }
                        else if (td.hasClass('total')){
                            td.empty().append('<strong>Total</strong>');
                        }
                        else{
                            td.empty()
                            td.append(value.toLocaleString());
                        }
                    }
                    else{
                        if (td.hasClass('total')){
                            td.empty().append('<strong>Total</strong>');
                        }
                        else if (td.hasClass('currency')){
                            td.empty().append(parseInt(0))
                        }
                        else if(td.hasClass('percentage')){
                            td.empty().append('0')
                        }else if(td.hasClass('no-data')){
                            td.empty()
                        }
                        else{
                            td.empty().append('0');
                        }
                    }

                });
            },
            info: true,
            dom: "" + //<'row'<'col-12'<'input-group'f>>> <'col-sm-12 col-md-6'l>
                "<'row'<'col-sm-12'tr>>" +
                "<'row'<'col-12 align-items-center text-center'i><'col-12 align-items-center text-center'p>>",
            "pageLength": 20,
            pagingType: 'full_numbers',
            order: allowSort ? [[$(that).find('th').length - 1, 'desc']] : false, // Sort on the last column
            columnDefs: [{
                "targets": 'no-sort',
                "orderable": false
            }, {
                "targets": 'numeric',
                "render": $.fn.dataTable.render.number(',', '.', 0)
            }, {
                "targets": 'text-right-report',
                "class": 'text-right'
            },  {
                "targets": 'checkbox',
                "class": 'no-dispay-checkbox'
            },{
                "targets": 'text-right',
                "class": 'text-right text-nowrap'
            },{
                "targets": 'text-left',
                "class": 'text-left'
            },{
                "targets": 'bmro-company-width',
                "class": 'bmro-company-width'
            },{
                "targets": 'bmro-quick-actions-width',
                "class": 'bmro-quick-actions-width'
            },{
                "targets": 'bmro-inquiry-width',
                "class": 'bmro-inquiry-width'
            },{
                "targets": 'bmro-sales-invoice-sub-width',
                "class": 'bmro-sales-invoice-sub-width'
            },{
                "targets": 'bmro-date-width',
                "class": 'bmro-date-width'
            },{
                "targets": 'bmro-sap-status-width',
                "class": 'bmro-sap-status-width'
            },{
                "targets": 'bmro-inside-sale-width',
                "class": 'bmro-inside-sale-width'
            }, {
                    "targets": 'text-center',
                    "class": 'text-center text-nowrap'
                },{
                "targets": 'row-group',
                "class": 'row-group'
            }],
            rowGroup: {dataSrc: [ 1 ]},
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
                let clear = $('<input type="button" name="clear-btn" value="Reset" class="bmro-button bmro-set-size reset-table-filters">');
                $('.reset-table-filters').on('click', function (e) {
                    $('.fillter-wrapper .select2-ajax').val('').trigger('change')
                    $('.fillter-wrapper .select').val('').trigger('change')
                    $('.fillter-wrapper [data-toggle="daterangepicker"]').val('').trigger('change')
                    $('.bmro-table-layout [data-toggle="daterangepicker"]').val('')
                    $('.bmro-search-width').val('')
                    $('.bmro-date-bag').val('');
                });
                actionTd.append(clear);
                var data_multiclass = [];
                this.api().columns().every(function () {
                    let column = this;
                    let filter = $(table).find('thead tr:eq(1) td:eq(' + column.index() + ')').data('filter');
                    let td = $(table).find('thead tr:eq(1) td:eq(' + column.index() + ')');
                    let text = $(column.header()).text();
                    // Uses the window.hasher to get column-level filters, if defined, to set selected value that will allow filtering the datatable
                    let selected = (filter == 'dropdown' || filter == 'ajax') ? window.hasher.getParam(text).split('|') : window.hasher.getParam(text);

                    if (filter && filter != false) {
                        let input = '';
                        if (filter == 'dropdown') {
                            let status_class = ((text == 'Status' || text == 'SAP Status') ? 'status-filter': '');
                            input = $('<div class="bmro-input-search bmro-arrow-parent '+status_class+'"><select class="form-control select select2-single bmro-form-input select2-hidden-accessible" data-placeholder="' + [text, ' '].join('') + '"><option value="" selected disabled></option></select></div>');
                            json.columnFilters[this.index()].forEach(function (f) {
                                let option = $('<option value="' + f.value + '">' + f.label + '</option>');
                                input.find('select').append(option);
                            });
                        } else if (filter == 'daterange') {
                            var dataNameTemp = $(column.header()).data('name')
                            let date_class = ((dataNameTemp == 'mis_date')||(dataNameTemp=='po_date')||(dataNameTemp=='created_at')) ? 'date-item hide '+dataNameTemp: '';
                            if(data_multiclass.length == 0){
                                data_multiclass.push(dataNameTemp)
                            }else if(data_multiclass.includes('mis_date' || 'po_date') && dataNameTemp=='created_at'){
                                $('.date-item').not('.created_at').removeClass("hide")
                            }
                            input = $('<div class="bmro-input-search bmro-arrow-parent '+date_class+'"><input class="form-control" data-toggle="daterangepicker" placeholder="' + 'Pick a date range" /></div>');
                        } else if (filter == 'ajax') {
                            let source = "";
                            json.columnFilters[this.index()].forEach(function (f) {
                                source = f.source;
                            });
                            input = $('<div class="bmro-input-search bmro-arrow-parent"><select class="form-control select2-ajax" data-source="' + source + '" data-placeholder="' + [text, ' '].join('') + '"></select></div>');
                        } else {
                            input = $('<div class="bmro-input-search bmro-arrow-parent"><input type="text" class="form-control" placeholder="' + [text, ' ', 'Filter'].join('') + '" /></div>');
                        }
                        input.on('change', function () {
                            let val
                            if (input.has('input').length > 0){
                                val = $(this).find('input').val();
                                column.search(val).draw();
                            } else if (input.has('select').length > 0){
                                val = $(this).find('select').val();
                                column.search(val).draw();
                            }

                            // Override the value for dropdowns/select2s in the text|value format
                            if ($(input).is('select'))
                                val = val ? [$(this).find('option:selected').text(), "|", val].join('') : '';

                            // Set URL Hash parameter for this specific column
                            window.hasher.setParam(text, val);

                            // Set a custom event that triggers on any of the filters being changed
                            $(that).trigger('filters:change');
                        });

                        $('.fillter-wrapper').append(input);
                        select2s();



                        // If filters are defined, we use selected to set drodpowns, textboxes and select2 DOM elements to filter the datatable
                        if (selected == "") return;
                        $(this).data('filtered', false);
                        if (filter == 'dropdown') {
                            input.find('select').val(selected[1]).trigger('change');
                        } else if (filter == 'ajax') {
                            input.find('select').append(new Option(selected[0], selected[1], true, true)).trigger('change');
                        } else {
                            input.find('select').val(selected).trigger('change');
                        }
                    }
                });
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

            // If filters are defined, this triggers all of them and sets filtered state to true
            if (!$(this).data('filtered')) {
                $('.filter-list-input').val('').trigger('keyup');
                $(this).data('filtered', true);
            }
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

$('.reset-table-filters').on('click', function(){
    $('.fillter-wrapper .select2-ajax').val('').trigger('change')
    $('.fillter-wrapper .select').val('').trigger('change')
    $('.fillter-wrapper [data-toggle="daterangepicker"]').val('').trigger('change')
    $('.bmro-table-layout [data-toggle="daterangepicker"]').val('')
    $('.bmro-date-bag').val('');
})

export default dataTables