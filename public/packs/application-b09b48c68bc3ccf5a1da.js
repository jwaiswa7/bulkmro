/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, {
/******/ 				configurable: false,
/******/ 				enumerable: true,
/******/ 				get: getter
/******/ 			});
/******/ 		}
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "/packs/";
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = 14);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/*!************************************************************************!*\
  !*** ./app/assets/javascripts/packs/views/imports/manageFailedSkus.js ***!
  \************************************************************************/
/*! exports provided: default */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
var manageFailedSkus = function manageFailedSkus() {
    $(':input:visible:radio:checked').each(function (e) {
        onRadioChange(this);
    });

    $('input[name*=approved_alternative_id]:radio').on('change', function (e) {
        onRadioChange(this);
    });
};

var onRadioChange = function onRadioChange(radio) {
    var newProductForm = $(radio).closest('div.option-wrapper').find('div.nested');

    if (isNaN(radio.value)) {
        newProductForm.find(':input:visible:not(:radio)').prop('disabled', false).prop('required', true);
    } else {
        newProductForm.find(':input:visible:not(:radio)').prop('disabled', true).prop('required', false);
    }
};

/* harmony default export */ __webpack_exports__["default"] = (manageFailedSkus);

/***/ }),
/* 1 */
/*!***********************************************************************!*\
  !*** ./app/assets/javascripts/packs/views/inquiries/editSuppliers.js ***!
  \***********************************************************************/
/*! exports provided: default */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
var editSuppliers = function editSuppliers() {
    $('form[action$=update_suppliers]').on('change', 'select[name*=supplier_id]', function (e) {
        onSupplierChange(this);
    }).on('click', '.update-with-best-price', function (e) {
        var parent = $(this).parent();
        var input = parent.find('input');
        parent.closest('div.row').find('[name*=unit_cost_price]').val(input.val());
    }).find('select[name*=supplier_id]').each(function (e) {
        onSupplierChange(this);
    });
};

var onSupplierChange = function onSupplierChange(container) {
    var optionSelected = $("option:selected", container);
    var select = $(container).closest('select');

    if (optionSelected.exists() && optionSelected.val() !== '') {
        $.getJSON({
            url: Routes.best_prices_overseers_product_path(select.data('product-id')),
            data: {
                supplier_id: optionSelected.val(),
                inquiry_product_supplier_id: select.data('inquiry-product-supplier-id')
            },

            success: function success(response) {
                select.closest('div.row').find('[name*=lowest_unit_cost_price]').val(response.lowest_unit_cost_price);
                select.closest('div.row').find('[name*=latest_unit_cost_price]').val(response.latest_unit_cost_price);
            }
        });
    }
};

/* harmony default export */ __webpack_exports__["default"] = (editSuppliers);

/***/ }),
/* 2 */
/*!*************************************************************!*\
  !*** ./app/assets/javascripts/packs/components/select2s.js ***!
  \*************************************************************/
/*! exports provided: default */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
// Converts select to select2
var select2s = function select2s() {
    $('.select2-single:not(.select2-ajax), .select2-multiple:not(.select2-ajax)').select2({
        theme: "bootstrap",
        containerCssClass: ':all:'
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
};

/* harmony default export */ __webpack_exports__["default"] = (select2s);

/***/ }),
/* 3 */
/*!*********************************************************!*\
  !*** ./app/assets/javascripts/packs/views/loadViews.js ***!
  \*********************************************************/
/*! exports provided: default */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
// Imports
var loader = {};
var importAll = function importAll(r) {
    r.keys().forEach(function (key) {
        // Remove any files under the /views directory
        if (key.split('/')[1].includes('.js')) return;

        // Get the controller name
        var controller = key.split('/')[1];

        // Get the function
        var view = r(key).default;

        // Set the functions relative to the controllers
        loader[controller] = loader[controller] ? loader[controller] : {};
        loader[controller][view.name] = r(key).default;
    });
};
importAll(__webpack_require__(/*! ./ */ 13));

var loadViews = function loadViews() {
    var dataAttributes = $('body').data();
    var controller = camelize(dataAttributes.controller);
    var controllerAction = camelize(dataAttributes.controllerAction);

    console.log(controller);
    console.log(controllerAction);

    if (controller in loader && controllerAction in loader[controller]) {

        loader[controller][controllerAction]();
        console.log("loader[" + controller + "][" + controllerAction + "]");
    }
};

var camelize = function camelize(text) {
    var separator = arguments.length <= 1 || arguments[1] === undefined ? '_' : arguments[1];
    var words = text.split(separator);
    var camelized = [words[0]].concat(words.slice(1).map(function (word) {
        return '' + word.slice(0, 1).toUpperCase() + word.slice(1).toLowerCase();
    }));

    console.log(camelized);

    return camelized.join('');
};

/* harmony default export */ __webpack_exports__["default"] = (loadViews);

/***/ }),
/* 4 */
/*!************************************************************************!*\
  !*** ./app/assets/javascripts/packs/views/imports/createFailedSkus.js ***!
  \************************************************************************/
/*! exports provided: default */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__manageFailedSkus__ = __webpack_require__(/*! ./manageFailedSkus */ 0);
// Imports


var createFailedSkus = function createFailedSkus() {
    Object(__WEBPACK_IMPORTED_MODULE_0__manageFailedSkus__["default"])();
};

/* harmony default export */ __webpack_exports__["default"] = (createFailedSkus);

/***/ }),
/* 5 */
/*!*************************************************************************!*\
  !*** ./app/assets/javascripts/packs/views/inquiries/updateSuppliers.js ***!
  \*************************************************************************/
/*! exports provided: default */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__editSuppliers__ = __webpack_require__(/*! ./editSuppliers */ 1);
// Imports


var updateSuppliers = function updateSuppliers() {
    Object(__WEBPACK_IMPORTED_MODULE_0__editSuppliers__["default"])();
};

/* harmony default export */ __webpack_exports__["default"] = (updateSuppliers);

/***/ }),
/* 6 */
/*!*********************************************************************!*\
  !*** ./app/assets/javascripts/packs/components/customFileInputs.js ***!
  \*********************************************************************/
/*! exports provided: default */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
// Makes sure that the custom file inputs have the highlighted border on file selection
var customFileInputs = function customFileInputs() {
    $('.custom-file-input').on('change', function () {
        $(this).next('.custom-file-label').addClass("selected").html($(this).val().split('\\').slice(-1)[0]);
    });
};

/* harmony default export */ __webpack_exports__["default"] = (customFileInputs);

/***/ }),
/* 7 */
/*!*************************************************************!*\
  !*** ./app/assets/javascripts/packs/components/tooltips.js ***!
  \*************************************************************/
/*! exports provided: default */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
// Attach popper.js Bootstrap tooltips to all tooltip triggers; including dynamically created elements
var tooltips = function tooltips() {
    $('body').tooltip({
        selector: '[data-toggle="tooltip"]'
    });
};

/* harmony default export */ __webpack_exports__["default"] = (tooltips);

/***/ }),
/* 8 */
/*!*********************************************************************!*\
  !*** ./app/assets/javascripts/packs/components/textareaAutosize.js ***!
  \*********************************************************************/
/*! exports provided: default */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
// Resize all texareas (even those dynamically added) when new lines are needed to remove the need for scrolling within a textarea
var textareaAutosize = function textareaAutosize() {
    autosize(document.querySelectorAll('textarea'));
};

/* harmony default export */ __webpack_exports__["default"] = (textareaAutosize);

/***/ }),
/* 9 */
/*!****************************************************************!*\
  !*** ./app/assets/javascripts/packs/components/nestedForms.js ***!
  \****************************************************************/
/*! exports provided: default */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__select2s__ = __webpack_require__(/*! ./select2s */ 2);
// Component Imports


// Handles dynamic additions of fields to nested forms
var nestedForms = function nestedForms() {
    $('body').on("fields_added.nested_form_fields", function (e, param) {
        Object(__WEBPACK_IMPORTED_MODULE_0__select2s__["default"])();
    }).on("fields_removed.nested_form_fields", function (e, param) {
        Object(__WEBPACK_IMPORTED_MODULE_0__select2s__["default"])();
    });
};

/* harmony default export */ __webpack_exports__["default"] = (nestedForms);

/***/ }),
/* 10 */
/*!********************************************************************!*\
  !*** ./app/assets/javascripts/packs/components/googleAnalytics.js ***!
  \********************************************************************/
/*! exports provided: default */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
// GA ping for pageview
var googleAnalytics = function googleAnalytics() {
    if (typeof ga === 'function') {
        ga('set', 'location', event.data.url);
        return ga('send', 'pageview');
    }
};

/* harmony default export */ __webpack_exports__["default"] = (googleAnalytics);

/***/ }),
/* 11 */
/*!***********************************************************************!*\
  !*** ./app/assets/javascripts/packs/components/parselyValidations.js ***!
  \***********************************************************************/
/*! exports provided: default */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
// Parsely JS overrides for browser/bootstrap validations
var parselyValidations = function parselyValidations() {
    $.extend(window.Parsley.options, {
        errorClass: 'is-invalid',
        successClass: 'is-valid',
        errorsWrapper: '<div class="invalid-feedback"></div>',
        errorTemplate: '<span></span>',
        trigger: 'change',
        errorsContainer: function errorsContainer(e) {
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
};

/* harmony default export */ __webpack_exports__["default"] = (parselyValidations);

/***/ }),
/* 12 */
/*!***************************************************************!*\
  !*** ./app/assets/javascripts/packs/components/dataTables.js ***!
  \***************************************************************/
/*! exports provided: default */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
var dataTables = function dataTables() {
    preSetup();
    setup();
    ajax();
};

// Setup the filter field before all dataTables, if the filter attribute exists
var preSetup = function preSetup() {
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

            var $wrapper = "<div class='input-group input-group-round'>" + "<div class='input-group-prepend'>" + "<span class='input-group-text'>" + "<i class='material-icons'>filter_list</i>" + "</span>" + "</div>" + "</div>";

            var $filter = $($wrapper).append($input);

            $filter.insertBefore($target);
            $target.data('has-search', true);
        }
    });
};

// Initialize and setup all dataTables
var setup = function setup() {
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
            "<'row'<'col-sm-12'tr>>" + "<'row'<'col-12  align-items-center text-center'i><'col-12 align-items-center text-center'p>>",
            pagingType: 'full_numbers',
            order: [[$(that).find('th').length - 1, 'desc']], // Sort on the last column
            columnDefs: [{
                "targets": 'no-sort',
                "orderable": false
            }, {
                "targets": 'numeric',
                "render": $.fn.dataTable.render.number(',', '.', 0)
            }],
            fnServerParams: function fnServerParams(data) {
                data['columns'].forEach(function (items, index) {
                    data['columns'][index]['name'] = $(that).find('th:eq(' + index + ')').text();
                });
            },
            responsive: {
                details: {
                    renderer: function renderer(api, rowIdx, columns) {
                        var $data = $.map(columns, function (col, i) {
                            return col.hidden ? '<li class="list-group-item" data-dt-row="' + col.rowIndex + '" data-dt-column="' + col.columnIndex + '">' + (col.title ? '<span><strong>' + col.title + '</strong><br>' : '') + col.data + '</span>' + '</li>' : '';
                        }).join('');

                        return $data ? $('<ul/>').addClass('list-group').append($data) : false;
                    }
                }
            },

            language: {
                processing: '<i class="fal fa-spinner-third fa-spin fa-3x fa-fw"></i>' + '<span class="sr-only">Loading...</span>',
                paginate: {
                    first: '<i class="fal fa-arrow-to-left"></i>',
                    previous: '<i class="fal fa-angle-left"></i>',
                    next: '<i class="fal fa-angle-right"></i>',
                    last: '<i class="fal fa-arrow-to-right"></i>'
                }
            }
        });
    });
};

// How to handle datatTables which have an ajax attribute defined
var ajax = function ajax() {
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
var cleanUp = function cleanUp() {
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

/* harmony default export */ __webpack_exports__["default"] = (dataTables);

/***/ }),
/* 13 */
/*!**************************************************!*\
  !*** ./app/assets/javascripts/packs/views \.js$ ***!
  \**************************************************/
/*! dynamic exports provided */
/*! all exports used */
/***/ (function(module, exports, __webpack_require__) {

var map = {
	"./imports/createFailedSkus.js": 4,
	"./imports/manageFailedSkus.js": 0,
	"./inquiries/editSuppliers.js": 1,
	"./inquiries/updateSuppliers.js": 5,
	"./loadViews.js": 3
};
function webpackContext(req) {
	return __webpack_require__(webpackContextResolve(req));
};
function webpackContextResolve(req) {
	var id = map[req];
	if(!(id + 1)) // check for number or string
		throw new Error("Cannot find module '" + req + "'.");
	return id;
};
webpackContext.keys = function webpackContextKeys() {
	return Object.keys(map);
};
webpackContext.resolve = webpackContextResolve;
module.exports = webpackContext;
webpackContext.id = 13;

/***/ }),
/* 14 */
/*!*****************************************************!*\
  !*** ./app/assets/javascripts/packs/application.js ***!
  \*****************************************************/
/*! no exports provided */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__components_customFileInputs__ = __webpack_require__(/*! ./components/customFileInputs */ 6);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__components_select2s__ = __webpack_require__(/*! ./components/select2s */ 2);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2__components_tooltips__ = __webpack_require__(/*! ./components/tooltips */ 7);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3__components_textareaAutosize__ = __webpack_require__(/*! ./components/textareaAutosize */ 8);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4__components_nestedForms__ = __webpack_require__(/*! ./components/nestedForms */ 9);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5__components_googleAnalytics__ = __webpack_require__(/*! ./components/googleAnalytics */ 10);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_6__components_parselyValidations__ = __webpack_require__(/*! ./components/parselyValidations */ 11);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_7__components_dataTables__ = __webpack_require__(/*! ./components/dataTables */ 12);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_8__views_loadViews__ = __webpack_require__(/*! ./views/loadViews */ 3);
/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

// Component Imports










// Namespacing all imports under app
var app = {};

// Initaialize all components
app.initializeComponents = function () {
    Object(__WEBPACK_IMPORTED_MODULE_0__components_customFileInputs__["default"])();
    Object(__WEBPACK_IMPORTED_MODULE_1__components_select2s__["default"])();
    Object(__WEBPACK_IMPORTED_MODULE_2__components_tooltips__["default"])();
    Object(__WEBPACK_IMPORTED_MODULE_3__components_textareaAutosize__["default"])();
    Object(__WEBPACK_IMPORTED_MODULE_4__components_nestedForms__["default"])();
    Object(__WEBPACK_IMPORTED_MODULE_5__components_googleAnalytics__["default"])();
    Object(__WEBPACK_IMPORTED_MODULE_6__components_parselyValidations__["default"])();
    Object(__WEBPACK_IMPORTED_MODULE_7__components_dataTables__["default"])();
};

// Turbolinks load event
document.addEventListener("turbolinks:load", function () {
    app.initializeComponents();

    // Load all views
    Object(__WEBPACK_IMPORTED_MODULE_8__views_loadViews__["default"])();
});

/***/ })
/******/ ]);
//# sourceMappingURL=application-b09b48c68bc3ccf5a1da.js.map