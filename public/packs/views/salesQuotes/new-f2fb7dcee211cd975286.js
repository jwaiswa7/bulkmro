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
/******/ 	return __webpack_require__(__webpack_require__.s = 0);
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
var newAction = function newAction() {
    var vj = initVueJS();

    $('body').on("fields_added.nested_form_fields", function (e, params) {
        vj.$destroy();
        vj = initVueJS();
    }).on("fields_removing.nested_form_fields", function (e, params) {
        vj.$destroy();
        vj = initVueJS();
    });
};

var initVueJS = function initVueJS() {
    return new Vue({
        el: 'form',
        data: assignEventsAndGetAttributes(),
        watch: {
            rows: {
                handler: function handler(oldVal, newVal) {
                    this.rowsUpdated();
                },

                deep: true
            },
            conversion_rate: function conversion_rate() {
                this.updateConvertedSellingPrices();
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
            rowUpdated: function rowUpdated(index) {
                var row = this.getRow(index);
                // perform calculations
                this.updateConvertedSellingPriceFor(index);

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
                var total = 0;
                this.rows.forEach(function (row, index) {
                    total += parseFloat(row.freight_cost_subtotal);
                });
                this.calculated_freight_cost_total = total;
            },
            dropdownChanged: function dropdownChanged(e) {
                var container = e.target;
                var optionSelected = $("option:selected", container);
                var _this = this;

                $.each(optionSelected.data(), function (k, v) {
                    _this[underscore(k)] = v;
                });
            },
            quantityChangedFor: function quantityChangedFor(index) {
                this.triggerFreightChangeFor(index, 'quantity');
            },
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

                row.unit_cost_price_with_unit_freight_cost = toDecimal(row.unit_freight_cost) + toDecimal(row.unit_cost_price);

                this.setRow(index, row);
            },
            triggerSellingPriceChangeFor: function triggerSellingPriceChangeFor(index, trigger) {
                var row = this.getRow(index);

                console.dir(row);
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
            updateConvertedSellingPriceFor: function updateConvertedSellingPriceFor(index) {
                var row = this.getRow(index);
                row.converted_unit_selling_price = toDecimal(row.unit_selling_price) / toDecimal(this.getAttribute('conversion_rate'));
                this.setRow(index, row);
            },
            updateConvertedSellingPrices: function updateConvertedSellingPrices() {
                var _this = this;

                _this.rows.forEach(function (row, currentRowIndex) {
                    _this.updateConvertedSellingPriceFor(currentRowIndex);
                });
            }
        }
    });
};

var assignEventsAndGetAttributes = function assignEventsAndGetAttributes() {
    var rows = [];
    var data = {};

    // Handle repeatable rows
    $('[data-index]').each(function (index, row) {
        var currentRowIndex = $(row).data('index');

        if ($(row).is(':visible')) {
            var currentRowTemplate = {};

            // Bind attributes
            $(row).find('[data-bind]').each(function (index, el) {
                var attributeName = el.name.match(/\[([a-z_]*)\]$/)[1];
                var attributeVal = $(el).val();

                // To recreate VueJS v-model when nested form rows are added or removed
                $(el).attr("v-model", ["rows[", currentRowIndex, "].", attributeName].join(''));
                currentRowTemplate[attributeName] = attributeVal;

                assignDataEventsAsEvents(el, currentRowIndex);
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
        attributeName = el.name.match(/\[([a-z_]*)\]$/)[1];

        var methodName = camelize([attributeName, 'Changed', 'For'].join('_'));

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

/***/ })
/******/ ]);
//# sourceMappingURL=new-f2fb7dcee211cd975286.js.map