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
/******/ 	return __webpack_require__(__webpack_require__.s = 7);
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
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__components_select2s__ = __webpack_require__(/*! ../../components/select2s */ 1);


var newAction = function newAction() {

    var vj = initVueJS();
    $('body').on("fields_added.nested_form_fields", function (e, params) {
        vj.$destroy();

        vj = initVueJS();
    }).on("fields_removing.nested_form_fields", function (e, params) {
        vj.$destroy();

        vj = initVueJS();
    });

    $('body').on('change.select2', function (e, params) {});
};

var destroySelect = function destroySelect() {
    if ($('.select2-single:not(.select2-ajax), .select2-multiple:not(.select2-ajax)').select2()) {
        $('.select2-single:not(.select2-ajax), .select2-multiple:not(.select2-ajax)').select2('destroy');
    }

    $('select.select2-ajax').each(function (k, v) {
        if ($(this).select2()) {
            $(this).select2('destroy');
        }
    });
};

var initVueJS = function initVueJS() {
    var vj = new Vue({
        el: 'form',
        data: assignEventsAndGetAttributes(),
        mounted: function mounted() {
            this.updateSelectElements();
            this.rowsUpdated();
        },

        watch: {
            rows: {
                handler: function handler(oldVal, newVal) {
                    this.rowsUpdated();
                },

                deep: true
            },
            conversion_rate: function conversion_rate() {
                this.calculateConvertedSellingPrices();
            },

            check: {
                handler: function handler(oldVal, newVal) {
                    //console.log(this.getCheckedRows());
                    this.rowsUpdated();
                },

                deep: true
            }
        },
        computed: {
            totalFreightCost: function totalFreightCost() {
                // let total = 0;
                //
                // this.rows.forEach(function (row, index) {
                //     total += parseFloat(row.freight_cost_subtotal);
                // });
                //
                // return total;
            }
        },

        methods: {
            getAttribute: function getAttribute(name) {
                return this[name];
            },
            getRow: function getRow(index) {
                return this.rows[index];
            },
            setRow: function setRow(index, row) {
                if (row !== undefined) {
                    this.rows[index] = row;
                }
            },
            dropRow: function dropRow(index) {
                var row = this.getRow(index);
                for (var property in row) {
                    if (row.hasOwnProperty(property)) {
                        row[property] = 0;
                    }
                }
                this.setRow(index, row);
            },
            getCheckedRows: function getCheckedRows() {
                var checkedSupplierIds = [];
                var checkedRows = [];
                var checked = this.getAttribute("check");
                for (var property in checked) {
                    if (checked.hasOwnProperty(property)) {
                        checkedSupplierIds.push(checked[property]);
                    }
                }

                this.rows.forEach(function (row, currentRowIndex) {
                    if (checkedSupplierIds.includes(row.inquiry_product_supplier_id)) {
                        row.index = currentRowIndex;
                        checkedRows[currentRowIndex] = row;
                    }
                });

                return checkedRows;
            },
            rowUpdated: function rowUpdated(index) {
                this.updateConvertedSellingPriceFor(index);
                this.triggerSellingPriceChangeFor(index, 'margin_percentage');
                this.recalculateRowTotals(index);
            },
            recalculateRowTotals: function recalculateRowTotals(index) {
                console.log();
                var row = this.getRow(index);
                row.total_selling_price = toDecimal(row.unit_selling_price * row.quantity);
                var tax = parseFloat(row.total_selling_price * row.tax_percentage / 100);
                row.total_selling_price_with_tax = toDecimal(parseFloat(row.total_selling_price) + parseFloat(tax));
                this.setRow(index, row);
            },
            rowsUpdated: function rowsUpdated() {
                var _this = this;
                _this.rows.forEach(function (row, currentRowIndex) {
                    _this.rowUpdated(currentRowIndex);
                });
                this.afterRowsUpdated();
            },
            afterRowsUpdated: function afterRowsUpdated() {
                var calculated_freight_cost_total = 0,
                    total_selling_price = 0,
                    total_cost_price = 0,
                    total_selling_price_with_tax = 0,
                    margin_percentage = 0;
                var checkedRows = this.getCheckedRows();
                checkedRows.forEach(function (row, index) {
                    calculated_freight_cost_total += parseFloat(row.freight_cost_subtotal);
                    total_selling_price += parseFloat(row.total_selling_price);
                    total_selling_price_with_tax += parseFloat(row.total_selling_price_with_tax);
                    total_cost_price += parseFloat(row.unit_cost_price_with_unit_freight_cost * row.quantity);
                    margin_percentage += parseFloat(row.margin_percentage);
                });
                this.calculated_total_margin = toDecimal(total_selling_price - total_cost_price);
                this.average_margin_percentage = toDecimal(this.calculated_total_margin) / checkedRows.length;
                this.calculated_total_tax = toDecimal(total_selling_price_with_tax - total_selling_price);
                this.calculated_total = toDecimal(total_selling_price);
                this.calculated_total_with_tax = toDecimal(total_selling_price_with_tax);
                this.calculated_freight_cost_total = toDecimal(calculated_freight_cost_total);
            },
            dropdownChanged: function dropdownChanged(e) {
                var container = e.target;
                var optionSelected = $("option:selected", container);
                var _this = this;

                $.each(optionSelected.data(), function (k, v) {
                    _this[underscore(k)] = v;
                });
                this.rowsUpdated();
            },
            quantityChangedFor: function quantityChangedFor(index) {
                this.triggerFreightChangeFor(index, 'quantity');
            },
            selectSupplierChangedFor: function selectSupplierChangedFor(index) {},
            freightCostSubtotalChangedFor: function freightCostSubtotalChangedFor(index) {
                this.triggerFreightChangeFor(index, 'freight_cost_subtotal');
            },
            unitFreightCostChangedFor: function unitFreightCostChangedFor(index) {
                this.triggerFreightChangeFor(index, 'unit_freight_cost');
            },
            unitCostPriceChangedFor: function unitCostPriceChangedFor(index) {
                this.triggerSellingPriceChangeFor(index);
            },
            unitCostPriceWithUnitFreightCostChangedFor: function unitCostPriceWithUnitFreightCostChangedFor(index) {
                this.triggerSellingPriceChangeFor(index);
            },
            marginPercentageChangedFor: function marginPercentageChangedFor(index) {
                this.triggerSellingPriceChangeFor(index, 'margin_percentage');
            },
            unitSellingPriceChangedFor: function unitSellingPriceChangedFor(index) {
                this.triggerSellingPriceChangeFor(index);
            },
            totalSellingPriceChangedFor: function totalSellingPriceChangedFor(index) {
                this.triggerSellingPriceChangeFor(index);
            },
            totalSellingPriceWithTaxChangedFor: function totalSellingPriceWithTaxChangedFor(index) {
                this.triggerSellingPriceChangeFor(index);
            },
            taxCodeIdChangedFor: function taxCodeIdChangedFor(index) {
                //console.log("triggered Changed")
            },
            taxPercentageChangedFor: function taxPercentageChangedFor(index) {},
            convertedUnitSellingPriceChangedFor: function convertedUnitSellingPriceChangedFor(index) {},
            changeSupplier: function changeSupplier(event) {
                /*let container = event.target;
                let optionSelected = $("option:selected", container);
                let select = $(container).closest('select');
                let _this = this;
                let row = select.data('row');
                if (_this.rows[row] !== undefined) {
                    $.each(optionSelected.data(), function (k, v) {
                        _this.rows[row][underscore(k)] = v;
                    });
                    this.triggerFreightChangeFor(row, 'quantity');
                }*/
            },
            sellingPriceChangedFor: function sellingPriceChangedFor(index) {
                // this.triggerSellingPriceChangeFor(index);
            },
            triggerFreightChangeFor: function triggerFreightChangeFor(index, trigger) {
                var row = this.getRow(index);

                var freight_cost_subtotal = row.freight_cost_subtotal;
                var unit_freight_cost = row.unit_freight_cost;
                var quantity = row.quantity;

                if (trigger === 'freight_cost_subtotal' && freight_cost_subtotal >= 0) {
                    row.unit_freight_cost = toDecimal(freight_cost_subtotal / quantity);
                } else if (trigger === 'unit_freight_cost' || trigger === 'quantity') {
                    row.freight_cost_subtotal = toDecimal(unit_freight_cost * quantity);
                }

                row.unit_cost_price_with_unit_freight_cost = parseFloat(row.unit_freight_cost) + parseFloat(row.unit_cost_price);

                this.setRow(index, row);
            },
            triggerSellingPriceChangeFor: function triggerSellingPriceChangeFor(index, trigger) {
                var row = this.getRow(index);

                //console.dir(row);
                var margin_percentage = row.margin_percentage;
                var unit_selling_price = row.unit_selling_price;
                var unit_cost_price_with_unit_freight_cost = row.unit_cost_price_with_unit_freight_cost;

                if (trigger === 'margin_percentage' && margin_percentage >= 0 && margin_percentage < 100) {
                    unit_selling_price = unit_cost_price_with_unit_freight_cost / (1 - margin_percentage / 100);
                    row.unit_selling_price = toDecimal(unit_selling_price);
                } else {
                    margin_percentage = 1 - unit_cost_price_with_unit_freight_cost / unit_selling_price;
                    row.margin_percentage = toDecimal(margin_percentage * 100);
                }
                this.setRow(index, row);
            },

            /*genericFunction() {
             },
            initRowAndExecute(index, callback) {
                let row = this.getRow(index);
                if (row !== undefined) {
                    callback(index);
                }
            },
            initRowAndExecuteWithTrigger(index, trigger, callback) {
                let row = this.getRow(index);
                if (row !== undefined) {
                    callback(index, trigger);
                }
            },*/
            updateConvertedSellingPriceFor: function updateConvertedSellingPriceFor(index) {
                var row = this.getRow(index);
                if (row !== undefined) {
                    row.converted_unit_selling_price = toDecimal(parseFloat(row.unit_selling_price) / parseFloat(this.getAttribute('conversion_rate')));
                }
                this.setRow(index, row);
            },
            calculateConvertedSellingPrices: function calculateConvertedSellingPrices() {
                var _this = this;

                _this.rows.forEach(function (row, currentRowIndex) {
                    _this.updateConvertedSellingPriceFor(currentRowIndex);
                });
            },
            updateSelectElements: function updateSelectElements() {
                setTimeout(function () {
                    destroySelect();
                    $('form [name*=tax_code_id]').addClass('select2-ajax');
                    Object(__WEBPACK_IMPORTED_MODULE_0__components_select2s__["default"])();
                    $('select.select2-ajax').each(function (k, v) {
                        $(this).select2({
                            theme: "bootstrap",
                            containerCssClass: ':all:',
                            ajax: {
                                url: $(this).attr('data-source'),
                                dataType: 'json',
                                delay: 100
                            },
                            processResults: function processResults(data, page) {
                                return { results: data };
                            }

                        }).on('change', function () {
                            //$(this).trigger('input');
                            var attributeName = this.name.match(/\[([a-z_]*)\]$/)[1];
                            var currentRowIndex = $(this).closest('div.simple-row').data('index');
                            //console.log(currentRowIndex,attributeName,this.value, vj.$data.rows[currentRowIndex][attributeName]);
                            vj.$data.rows[currentRowIndex][attributeName] = this.value;
                            //vj.$emit('input', this.value) // emitting Vue change event

                            var optionSelected = $("option:selected", this);
                            //console.log(optionSelected[0].text.match(/\w[\d]\.[\d]*/gm)[0])
                            vj.$data.rows[currentRowIndex]["tax_percentage"] = parseFloat(optionSelected[0].text.match(/\w[\d]\.[\d]*/gm)[0]);
                        });
                    });
                }, 1000);
            }
        }
    });

    return vj;
};

var assignEventsAndGetAttributes = function assignEventsAndGetAttributes() {
    var rows = [];
    var data = {
        "check": {}
    };

    // Handle repeatable rows
    $('[data-index]').each(function (index, row) {
        var currentRowIndex = $(row).data('index');

        if ($(row).is(':visible')) {
            var currentRowTemplate = {};

            // Bind attributes
            $(row).find('[data-bind]').each(function (index, el) {
                var attributeName = "";
                var modelName = "";
                if ($(el).data("bind") != "") {

                    modelName = $(el).data("bind");
                    if ($(el).is(":checked")) {
                        data["check"][modelName] = $(el).val();
                    }
                    $(el).attr("v-model", 'check.' + modelName + '');
                } else {
                    attributeName = el.name.match(/\[([a-z_]*)\]$/)[1];
                    modelName = ["rows[", currentRowIndex, "].", attributeName].join('');
                    var attributeVal = $(el).val();

                    // To recreate VueJS v-model when nested form rows are added or removed
                    $(el).attr("v-model", modelName);
                    //$(el).attr("data-v-index", currentRowIndex);
                    currentRowTemplate[attributeName] = attributeVal;
                }

                assignDataEventsAsEvents(el, currentRowIndex);
            });

            $(row).find('[data-v-html]').each(function (index, el) {

                var modelName = "";
                if ($(el).data("v-html") != "") {
                    var attributeName = $(el).data("v-html");
                    modelName = ["rows[", currentRowIndex, "].", attributeName].join('');
                    var attributeVal = 0;

                    // To recreate VueJS v-model when nested form rows are added or removed
                    $(el).attr("v-html", modelName);
                    //$(el).attr("data-v-index", currentRowIndex);
                    currentRowTemplate[attributeName] = attributeVal;
                }
            });

            // Bind non-input events like buttons
            $(row).find('[data-v]').each(function (index, element) {
                assignDataEventsAsEvents(element, currentRowIndex);
            });

            rows[currentRowIndex] = currentRowTemplate;
        }
    });

    // Independent of rows, like a total row
    $('[data-v-model]').each(function (index, el) {
        var attributeName = el.name.match(/\[([a-z_]*)\]$/)[1];
        var attributeValue = $(el).val();

        $(el).attr("v-model", attributeName);
        data[attributeName] = attributeValue;

        assignDataEventsAsEvents($(el), undefined);
    });

    // V-models that cannot be edited, auto calculated
    $('[data-v-computed]').each(function (index, el) {
        $(el).attr("v-model", $(el).attr('data-v-computed'));
    });
    data.rows = rows;
    return data;
};

var assignDataEventsAsEvents = function assignDataEventsAsEvents(el) {
    var currentRowIndex = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : '';

    var eventNames = ['v-on:change', 'v-on:input', 'v-on:click'];
    var attributeName = undefined;

    if (el.name !== undefined && el.name.trim() !== '') {

        var methodName = "";

        if ($(el).data("bind") != "") {
            attributeName = $(el).data("bind");
            methodName = [camelizeAndSkipLastWord(attributeName), 'Changed', 'For'].join('');
        } else {
            attributeName = el.name.match(/\[([a-z_]*)\]$/)[1];
            methodName = camelize([attributeName, 'Changed', 'For'].join('_'));
        }

        if (currentRowIndex !== '') {
            methodName += '(' + currentRowIndex + ')';
        }

        eventNames.forEach(function (eventName) {
            $(el).attr('v-on:input', methodName);
        });
    } else {
        eventNames.forEach(function (eventName) {
            if ($(el).data(eventName)) {
                $(el).attr(eventName, $(el).data(eventName).replace('_index_', currentRowIndex));
            }
        });
    }
};

var toDecimal = function toDecimal(value) {
    var precision = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : 2;

    return parseFloat(value).toFixed(precision);
};

/* harmony default export */ __webpack_exports__["default"] = (newAction);

/***/ }),
/* 1 */
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
            },
            processResults: function processResults(data, page) {
                return { results: data };
            }

        });
    }).on('change', function () {
        $(this).trigger('input');
    });
};

/* harmony default export */ __webpack_exports__["default"] = (select2s);

/***/ }),
/* 2 */
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
/* 3 */
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
/* 4 */
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
        var parent = $(this).closest('.input-group');
        var input = parent.find('input');
        parent.closest('div.form-row').find('[name*="[unit_cost_price]"]').val(input.val());
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
                select.closest('div.form-row').find('[name*=lowest_unit_cost_price]').val(response.lowest_unit_cost_price);
                select.closest('div.form-row').find('[name*=latest_unit_cost_price]').val(response.latest_unit_cost_price);
                select.closest('div.form-row').find('[name*=bp_catalog_name]').val(response.bp_catalog_name);
                select.closest('div.form-row').find('[name*=bp_catalog_sku]').val(response.bp_catalog_sku);
            }
        });
    }
};

/* harmony default export */ __webpack_exports__["default"] = (editSuppliers);

/***/ }),
/* 5 */
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
/* 6 */
/*!***************************************************************!*\
  !*** ./app/assets/javascripts/packs/views/salesOrders/new.js ***!
  \***************************************************************/
/*! exports provided: default */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__updateOnSelect__ = __webpack_require__(/*! ./updateOnSelect */ 2);
// Imports


var newAction = function newAction() {
    Object(__WEBPACK_IMPORTED_MODULE_0__updateOnSelect__["default"])();
};

/* harmony default export */ __webpack_exports__["default"] = (newAction);

/***/ }),
/* 7 */
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
importAll(__webpack_require__(/*! ./ */ 24));

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

/* harmony default export */ __webpack_exports__["default"] = (loadViews);

/***/ }),
/* 8 */
/*!************************************************************************!*\
  !*** ./app/assets/javascripts/packs/views/imports/createFailedSkus.js ***!
  \************************************************************************/
/*! exports provided: default */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__manageFailedSkus__ = __webpack_require__(/*! ./manageFailedSkus */ 3);
// Imports


var createFailedSkus = function createFailedSkus() {
    Object(__WEBPACK_IMPORTED_MODULE_0__manageFailedSkus__["default"])();
};

/* harmony default export */ __webpack_exports__["default"] = (createFailedSkus);

/***/ }),
/* 9 */
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
/* 10 */
/*!*************************************************************************!*\
  !*** ./app/assets/javascripts/packs/views/inquiries/updateSuppliers.js ***!
  \*************************************************************************/
/*! exports provided: default */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__editSuppliers__ = __webpack_require__(/*! ./editSuppliers */ 4);
// Imports


var updateSuppliers = function updateSuppliers() {
    Object(__WEBPACK_IMPORTED_MODULE_0__editSuppliers__["default"])();
};

/* harmony default export */ __webpack_exports__["default"] = (updateSuppliers);

/***/ }),
/* 11 */
/*!*************************************************************!*\
  !*** ./app/assets/javascripts/packs/views/products/edit.js ***!
  \*************************************************************/
/*! exports provided: default */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__new__ = __webpack_require__(/*! ./new */ 5);
// Imports


var edit = function edit() {
    Object(__WEBPACK_IMPORTED_MODULE_0__new__["default"])();
};

/* harmony default export */ __webpack_exports__["default"] = (edit);

/***/ }),
/* 12 */
/*!****************************************************************!*\
  !*** ./app/assets/javascripts/packs/views/salesOrders/edit.js ***!
  \****************************************************************/
/*! exports provided: default */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__new__ = __webpack_require__(/*! ./new */ 6);
// Imports


var edit = function edit() {
    Object(__WEBPACK_IMPORTED_MODULE_0__new__["default"])();
};

/* harmony default export */ __webpack_exports__["default"] = (edit);

/***/ }),
/* 13 */
/*!******************************************************************!*\
  !*** ./app/assets/javascripts/packs/views/salesQuotes/create.js ***!
  \******************************************************************/
/*! exports provided: default */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__new__ = __webpack_require__(/*! ./new */ 0);
// Imports


var create = function create() {
    Object(__WEBPACK_IMPORTED_MODULE_0__new__["default"])();
};

/* harmony default export */ __webpack_exports__["default"] = (create);

/***/ }),
/* 14 */
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
/* 15 */
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
/* 16 */
/*!******************************************************************!*\
  !*** ./app/assets/javascripts/packs/views/salesQuotes/update.js ***!
  \******************************************************************/
/*! exports provided: default */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__new__ = __webpack_require__(/*! ./new */ 0);
// Imports


var update = function update() {
    Object(__WEBPACK_IMPORTED_MODULE_0__new__["default"])();
};

/* harmony default export */ __webpack_exports__["default"] = (update);

/***/ }),
/* 17 */,
/* 18 */,
/* 19 */,
/* 20 */,
/* 21 */,
/* 22 */,
/* 23 */,
/* 24 */
/*!**************************************************!*\
  !*** ./app/assets/javascripts/packs/views \.js$ ***!
  \**************************************************/
/*! dynamic exports provided */
/*! all exports used */
/***/ (function(module, exports, __webpack_require__) {

var map = {
	"./imports/createFailedSkus.js": 8,
	"./imports/manageFailedSkus.js": 3,
	"./inquiries/edit.js": 9,
	"./inquiries/editSuppliers.js": 4,
	"./inquiries/updateSuppliers.js": 10,
	"./loadViews.js": 7,
	"./products/edit.js": 11,
	"./products/new.js": 5,
	"./salesOrders/edit.js": 12,
	"./salesOrders/new.js": 6,
	"./salesOrders/updateOnSelect.js": 2,
	"./salesQuotes/create.js": 13,
	"./salesQuotes/edit.js": 14,
	"./salesQuotes/new.js": 0,
	"./salesQuotes/newRevision.js": 15,
	"./salesQuotes/update.js": 16
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
webpackContext.id = 24;

/***/ })
/******/ ]);
//# sourceMappingURL=loadViews-502015d6d3838f19e635.js.map