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
/******/ 	return __webpack_require__(__webpack_require__.s = 10);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/*!***************************************************************!*\
  !*** ./app/assets/javascripts/packs/views/salesQuotes/new.js ***!
  \***************************************************************/
/*! exports provided: default */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__updateMarginAndSellingPrice__ = __webpack_require__(/*! ./updateMarginAndSellingPrice */ 1);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__updateOnSelect__ = __webpack_require__(/*! ./updateOnSelect */ 2);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2__updateFreightCostAndUnitFreightCost__ = __webpack_require__(/*! ./updateFreightCostAndUnitFreightCost */ 3);
// Imports




var newAction = function newAction() {
    Object(__WEBPACK_IMPORTED_MODULE_0__updateMarginAndSellingPrice__["default"])();
    Object(__WEBPACK_IMPORTED_MODULE_1__updateOnSelect__["default"])();
    Object(__WEBPACK_IMPORTED_MODULE_2__updateFreightCostAndUnitFreightCost__["default"])();
};

/* harmony default export */ __webpack_exports__["default"] = (newAction);

/***/ }),
/* 1 */
/*!***************************************************************************************!*\
  !*** ./app/assets/javascripts/packs/views/salesQuotes/updateMarginAndSellingPrice.js ***!
  \***************************************************************************************/
/*! exports provided: default */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
var updateMarginAndSellingPrice = function updateMarginAndSellingPrice() {
    $('form').on('change', "[name$='[margin_percentage]']", function (e) {
        updateValues(this, 'margin_percentage');
    }).on('keyup', "[name$='[margin_percentage]']", function (e) {
        updateValues(this, 'margin_percentage');
    }).on('change', "[name$='[unit_selling_price]']", function (e) {
        updateValues(this, 'unit_selling_price');
    }).on('keyup', "[name$='[unit_selling_price]']", function (e) {
        updateValues(this, 'unit_selling_price');
    });
};

var updateValues = function updateValues(container, trigger) {
    var margin_percentage = $(container).closest('div.nested_fields').find("[name$='[margin_percentage]']").val();
    var unit_selling_price = $(container).closest('div.nested_fields').find("[name$='[unit_selling_price]']").val();
    var unit_cost_price = $(container).closest('div.nested_fields').find("[name$='[unit_cost_price]']").val();
    if (trigger === 'margin_percentage') {
        if (margin_percentage >= 0 && margin_percentage < 100) {
            unit_selling_price = unit_cost_price / (1 - margin_percentage / 100);
            $(container).closest('div.nested_fields').find("[name$='[unit_selling_price]']").val(parseFloat(unit_selling_price).toFixed(2));
        }
    } else {
        margin_percentage = 1 - unit_cost_price / unit_selling_price;
        $(container).closest('div.nested_fields').find("[name$='[margin_percentage]']").val(parseFloat(margin_percentage * 100).toFixed(2));
    }
};

/* harmony default export */ __webpack_exports__["default"] = (updateMarginAndSellingPrice);

/***/ }),
/* 2 */
/*!**************************************************************************!*\
  !*** ./app/assets/javascripts/packs/views/salesQuotes/updateOnSelect.js ***!
  \**************************************************************************/
/*! exports provided: default */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
var updateOnSelect = function updateOnSelect() {
    $('form').on('change', 'select[name*=inquiry_product_supplier_id]', function (e) {
        onSupplierChange(this);
    });
};

var onSupplierChange = function onSupplierChange(container) {
    var optionSelected = $("option:selected", container);
    var select = $(container).closest('select');

    $.each(optionSelected.data(), function (k, v) {
        select.closest('div.row').find('[name*=' + underscore(k) + ']').val(v);
    });

    select.closest('div.row').find('[name*=margin_percentage]').change();
};

/* harmony default export */ __webpack_exports__["default"] = (updateOnSelect);

/***/ }),
/* 3 */
/*!***********************************************************************************************!*\
  !*** ./app/assets/javascripts/packs/views/salesQuotes/updateFreightCostAndUnitFreightCost.js ***!
  \***********************************************************************************************/
/*! exports provided: default */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
var updateTotalFreightCostAndUnitFreightCost = function updateTotalFreightCostAndUnitFreightCost() {
    $('form').on('change', "[name$='[freight_cost_subtotal]']", function (e) {
        updateValues(this, 'freight_cost_subtotal');
    }).on('keyup', "[name$='[freight_cost_subtotal]']", function (e) {
        updateValues(this, 'freight_cost_subtotal');
    }).on('change', "[name$='[unit_freight_cost_subtotal]']", function (e) {
        updateValues(this, 'unit_freight_cost');
    }).on('keyup', "[name$='[unit_freight_cost]']", function (e) {
        updateValues(this, 'unit_freight_cost');
    }).on('fields_removed.nested_form_fields', "", function (e) {
        updateValues(this, 'destroy');
    }).on('change', "[name$='[quantity]']", function (e) {
        updateValues(this, 'quantity');
    }).on('keyup', "[name$='[quantity]']", function (e) {
        updateValues(this, 'quantity');
    });
};

var updateValues = function updateValues(container, trigger) {
    var freight_cost_subtotal = $(container).closest('div.nested_fields').find("[name$='[freight_cost_subtotal]']").val();
    var unit_freight_cost = $(container).closest('div.nested_fields').find("[name$='[unit_freight_cost]']").val();
    var quantity = $(container).closest('div.nested_fields').find("[name$='[quantity]']").val();
    var freight_costs = $(container).closest('div.card-body').find("[name$='[calculated_freight_cost_total]']");
    var freight_cost_total = 0.0;

    if (trigger === 'freight_cost' || trigger === 'quantity') {
        if (freight_cost_subtotal >= 0) {
            unit_freight_cost = freight_cost_subtotal / quantity;
            $(container).closest('div.nested_fields').find("[name$='[unit_freight_cost]']").val(parseFloat(unit_freight_cost).toFixed(2));
        }
    } else if (trigger === 'unit_freight_cost') {
        var _freight_cost_subtotal = unit_freight_cost * quantity;
        $(container).closest('div.nested_fields').find("[name$='[freight_cost_subtotal]']").val(parseFloat(_freight_cost_subtotal).toFixed(2));
    } else {
        // TODO: UPDATE FREIGHT TOTAL ON DELETE
    }

    freight_costs.each(function () {
        freight_cost_total += parseFloat($(this).val());
    });

    $(container).closest('div.card-body').find("[name$='[calculated_freight_cost_total]']").val(parseFloat(freight_cost_total).toFixed(2));
};

/* harmony default export */ __webpack_exports__["default"] = (updateTotalFreightCostAndUnitFreightCost);

/***/ }),
/* 4 */
/*!**************************************************************************!*\
  !*** ./app/assets/javascripts/packs/views/salesOrders/updateOnSelect.js ***!
  \**************************************************************************/
/*! exports provided: default */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
var updateOnSelect = function updateOnSelect() {
    $('form').on('change', 'select[name*=sales_quote_row_id]', function (e) {
        onSalesQuoteRowChange(this);
    });
};

var onSalesQuoteRowChange = function onSalesQuoteRowChange(container) {
    var optionSelected = $("option:selected", container);
    var select = $(container).closest('select');

    $.each(optionSelected.data(), function (k, v) {
        select.closest('div.row').find('[name*=' + underscore(k) + ']').val(v);
    });
};

/* harmony default export */ __webpack_exports__["default"] = (updateOnSelect);

/***/ }),
/* 5 */
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
/* 6 */
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
            url: Routes.best_prices_and_supplier_bp_catalog_overseers_product_path(select.data('product-id')),
            data: {
                supplier_id: optionSelected.val(),
                inquiry_product_supplier_id: select.data('inquiry-product-supplier-id')
            },

            success: function success(response) {
                select.closest('div.row').find('[name*=lowest_unit_cost_price]').val(response.lowest_unit_cost_price);
                select.closest('div.row').find('[name*=latest_unit_cost_price]').val(response.latest_unit_cost_price);
                select.closest('div.row').find('[name*=bp_catalog_name]').val(response.bp_catalog_name);
                select.closest('div.row').find('[name*=bp_catalog_sku]').val(response.bp_catalog_sku);
            }
        });
    }
};

/* harmony default export */ __webpack_exports__["default"] = (editSuppliers);

/***/ }),
/* 7 */
/*!************************************************************!*\
  !*** ./app/assets/javascripts/packs/views/products/new.js ***!
  \************************************************************/
/*! exports provided: default */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });

var newAction = function newAction() {};

/* harmony default export */ __webpack_exports__["default"] = (newAction);

/***/ }),
/* 8 */
/*!***************************************************************!*\
  !*** ./app/assets/javascripts/packs/views/salesOrders/new.js ***!
  \***************************************************************/
/*! exports provided: default */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__updateOnSelect__ = __webpack_require__(/*! ./updateOnSelect */ 4);
// Imports


var newAction = function newAction() {
    Object(__WEBPACK_IMPORTED_MODULE_0__updateOnSelect__["default"])();
};

/* harmony default export */ __webpack_exports__["default"] = (newAction);

/***/ }),
/* 9 */,
/* 10 */
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
importAll(__webpack_require__(/*! ./ */ 25));

var loadViews = function loadViews() {
    var dataAttributes = $('body').data();
    var controller = camelize(dataAttributes.controller);
    var controllerAction = camelize(dataAttributes.controllerAction);

    if (controller in loader && controllerAction in loader[controller]) {
        loader[controller][controllerAction]();
        console.log("loader[" + controller + "][" + controllerAction + "]");
    } else if (controller in loader && controllerAction + 'Action' in loader[controller]) {
        loader[controller][controllerAction + 'Action']();
        console.log("loader[" + controller + "][" + controllerAction + "]");
    }
};

var camelize = function camelize(text) {
    var separator = arguments.length <= 1 || arguments[1] === undefined ? '_' : arguments[1];
    var words = text.split(separator);
    var camelized = [words[0]].concat(words.slice(1).map(function (word) {
        return '' + word.slice(0, 1).toUpperCase() + word.slice(1).toLowerCase();
    }));

    return camelized.join('');
};

/* harmony default export */ __webpack_exports__["default"] = (loadViews);

/***/ }),
/* 11 */
/*!************************************************************************!*\
  !*** ./app/assets/javascripts/packs/views/imports/createFailedSkus.js ***!
  \************************************************************************/
/*! exports provided: default */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__manageFailedSkus__ = __webpack_require__(/*! ./manageFailedSkus */ 5);
// Imports


var createFailedSkus = function createFailedSkus() {
    Object(__WEBPACK_IMPORTED_MODULE_0__manageFailedSkus__["default"])();
};

/* harmony default export */ __webpack_exports__["default"] = (createFailedSkus);

/***/ }),
/* 12 */
/*!**************************************************************!*\
  !*** ./app/assets/javascripts/packs/views/inquiries/edit.js ***!
  \**************************************************************/
/*! exports provided: default */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
var edit = function edit() {
    //TODO

    $('form').on('change', 'select[name*=product_id]', function (e) {
        onProductChange(this);
    }).find('select[name*=product_id]').each(function (e) {
        onProductChange(this);
    });

    /*
    *
    * Auto Add Position as per the last position when add to product adds a nested field
    *
    * */
    /*$(document).on('nested:fieldAdded', function (event) {
         var position = 1;
          positionInputs = $("input[name$='[position]']");
        console.log(positionInputs);
        if (positionInputs.length > 0) {
            if ($(positionInputs[positionInputs.length - 1]).val() !== "") {
                 position = parseInt($(positionInputs[positionInputs.length - 1]).val()) + 1;
             }
            $(positionInputs[positionInputs.length]).val(position);
        }
    });*/
};

var onProductChange = function onProductChange(container) {
    var optionSelected = $("option:selected", container);
    var select = $(container).closest('select');

    if (optionSelected.exists() && optionSelected.val() !== '') {
        $.getJSON({
            url: Routes.customer_bp_catalog_overseers_product_path(optionSelected.val()),
            data: {
                company_id: $('#inquiry_company_id').val()
            },

            success: function success(response) {
                select.closest('div.form-row').find('[name*=bp_catalog_name]').val(response.bp_catalog_name);
                select.closest('div.form-row').find('[name*=bp_catalog_sku]').val(response.bp_catalog_sku);
            }
        });
    }
};

/* harmony default export */ __webpack_exports__["default"] = (edit);

/***/ }),
/* 13 */
/*!*************************************************************************!*\
  !*** ./app/assets/javascripts/packs/views/inquiries/updateSuppliers.js ***!
  \*************************************************************************/
/*! exports provided: default */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__editSuppliers__ = __webpack_require__(/*! ./editSuppliers */ 6);
// Imports


var updateSuppliers = function updateSuppliers() {
    Object(__WEBPACK_IMPORTED_MODULE_0__editSuppliers__["default"])();
};

/* harmony default export */ __webpack_exports__["default"] = (updateSuppliers);

/***/ }),
/* 14 */
/*!*************************************************************!*\
  !*** ./app/assets/javascripts/packs/views/products/edit.js ***!
  \*************************************************************/
/*! exports provided: default */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__new__ = __webpack_require__(/*! ./new */ 7);
// Imports


var edit = function edit() {
    Object(__WEBPACK_IMPORTED_MODULE_0__new__["default"])();
};

/* harmony default export */ __webpack_exports__["default"] = (edit);

/***/ }),
/* 15 */
/*!****************************************************************!*\
  !*** ./app/assets/javascripts/packs/views/salesOrders/edit.js ***!
  \****************************************************************/
/*! exports provided: default */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__new__ = __webpack_require__(/*! ./new */ 8);
// Imports


var edit = function edit() {
    Object(__WEBPACK_IMPORTED_MODULE_0__new__["default"])();
};

/* harmony default export */ __webpack_exports__["default"] = (edit);

/***/ }),
/* 16 */
/*!****************************************************************!*\
  !*** ./app/assets/javascripts/packs/views/salesQuotes/edit.js ***!
  \****************************************************************/
/*! exports provided: default */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__new__ = __webpack_require__(/*! ./new */ 0);
// Imports


var edit = function edit() {
    Object(__WEBPACK_IMPORTED_MODULE_0__new__["default"])();
};

/* harmony default export */ __webpack_exports__["default"] = (edit);

/***/ }),
/* 17 */
/*!***********************************************************************!*\
  !*** ./app/assets/javascripts/packs/views/salesQuotes/newRevision.js ***!
  \***********************************************************************/
/*! exports provided: default */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__new__ = __webpack_require__(/*! ./new */ 0);
// Imports


var newRevision = function newRevision() {
    Object(__WEBPACK_IMPORTED_MODULE_0__new__["default"])();
};

/* harmony default export */ __webpack_exports__["default"] = (newRevision);

/***/ }),
/* 18 */,
/* 19 */,
/* 20 */,
/* 21 */,
/* 22 */,
/* 23 */,
/* 24 */,
/* 25 */
/*!**************************************************!*\
  !*** ./app/assets/javascripts/packs/views \.js$ ***!
  \**************************************************/
/*! dynamic exports provided */
/*! all exports used */
/***/ (function(module, exports, __webpack_require__) {

var map = {
	"./imports/createFailedSkus.js": 11,
	"./imports/manageFailedSkus.js": 5,
	"./inquiries/edit.js": 12,
	"./inquiries/editSuppliers.js": 6,
	"./inquiries/updateSuppliers.js": 13,
	"./loadViews.js": 10,
	"./products/edit.js": 14,
	"./products/new.js": 7,
	"./salesOrders/edit.js": 15,
	"./salesOrders/new.js": 8,
	"./salesOrders/updateOnSelect.js": 4,
	"./salesQuotes/edit.js": 16,
	"./salesQuotes/new.js": 0,
	"./salesQuotes/newRevision.js": 17,
	"./salesQuotes/updateFreightCostAndUnitFreightCost.js": 3,
	"./salesQuotes/updateMarginAndSellingPrice.js": 1,
	"./salesQuotes/updateOnSelect.js": 2
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
webpackContext.id = 25;

/***/ })
/******/ ]);
//# sourceMappingURL=loadViews-3615006ea1f8b2d17e93.js.map