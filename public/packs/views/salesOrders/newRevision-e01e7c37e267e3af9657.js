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
/******/ 	return __webpack_require__(__webpack_require__.s = 13);
/******/ })
/************************************************************************/
/******/ ({

/***/ 0:
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

/***/ 1:
/*!***************************************************************!*\
  !*** ./app/assets/javascripts/packs/views/salesOrders/new.js ***!
  \***************************************************************/
/*! exports provided: default */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__components_select2s__ = __webpack_require__(/*! ../../components/select2s */ 0);


var newAction = function newAction() {

    //assignEventsAndGetAttributes()

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

                this.rows.forEach(function (row, index) {

                    total_selling_price += parseFloat(row.total_selling_price);
                    total_selling_price_with_tax += parseFloat(row.total_selling_price_with_tax);
                    total_cost_price += parseFloat(row.unit_cost_price_with_unit_freight_cost * row.quantity);
                    margin_percentage += parseFloat(row.margin_percentage);
                });
                this.calculated_total_margin = toDecimal(total_selling_price - total_cost_price);
                this.average_margin_percentage = toDecimal(this.calculated_total_margin) / this.rows.length;
                this.calculated_total_tax = toDecimal(total_selling_price_with_tax - total_selling_price);
                this.calculated_total = toDecimal(total_selling_price);
                this.calculated_total_with_tax = toDecimal(total_selling_price_with_tax);
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
                //this.triggerFreightChangeFor(index, 'quantity');
                this.triggerSellingPriceChangeFor(index);
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
            formatCurrency: function formatCurrency(value) {
                var val = (value / 1).toFixed(2);
                return this.currencySign + val.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
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
        currencySign: "",
        "check": {},
        calculated_total_margin: 0,
        average_margin_percentage: 0,
        calculated_total_tax: 0,
        calculated_total: 0,
        calculated_total_with_tax: 0,
        calculated_freight_cost_total: 0
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
            // Show Model information in non-input element
            $(row).find('[data-bind-html]').each(function (index, el) {
                var modelName = "";
                if ($(el).data("bind-html") != "") {
                    var attributeName = $(el).data("bind-html");
                    modelName = ["rows[", currentRowIndex, "].", attributeName].join('');

                    // To recreate VueJS v-model when nested form rows are added or removed
                    $(el).attr("v-html", modelName);

                    //$(el).attr("data-v-index", currentRowIndex);
                    if (currentRowTemplate[attributeName] == undefined) {

                        var value = $(el).text().trim();
                        var numberValue = value;

                        //Check if first char is not a number
                        if (value.match("[^0-9]").index == 0) {
                            if (data.currencySign == "") {
                                data.currencySign = value.match("[^0-9]")[0];
                            }
                            $(el).attr("v-html", "formatCurrency(" + modelName + ")");
                            numberValue = value.replace(/[^0-9.]/g, "");
                        }

                        currentRowTemplate[attributeName] = parseFloat(numberValue);
                    }
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
    $('[data-v-html]').each(function (index, el) {

        var value = $(el).text().trim();
        var attributeValue = value;
        var attributeName = $(el).attr('data-v-html');
        var modelName = attributeName;
        //Check if first char is not a number
        if (value.match("[^0-9]").index == 0) {
            if (data.currencySign == "") {
                data.currencySign = value.match("[^0-9]")[0];
            }
            attributeName = "formatCurrency(" + modelName + ")";
            attributeValue = value.replace(/[^0-9.]/g, "");
        }

        $(el).attr("v-html", attributeName);
        data[modelName] = attributeValue;
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

/***/ 13:
/*!***********************************************************************!*\
  !*** ./app/assets/javascripts/packs/views/salesOrders/newRevision.js ***!
  \***********************************************************************/
/*! exports provided: default */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__new__ = __webpack_require__(/*! ./new */ 1);
// Imports


var newRevision = function newRevision() {
    Object(__WEBPACK_IMPORTED_MODULE_0__new__["default"])();
};

/* harmony default export */ __webpack_exports__["default"] = (newRevision);

/***/ })

/******/ });
//# sourceMappingURL=newRevision-e01e7c37e267e3af9657.js.map