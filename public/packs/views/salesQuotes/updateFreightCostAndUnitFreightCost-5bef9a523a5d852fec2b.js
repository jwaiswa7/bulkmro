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
/******/ 	return __webpack_require__(__webpack_require__.s = 3);
/******/ })
/************************************************************************/
/******/ ({

/***/ 3:
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

/***/ })

/******/ });
//# sourceMappingURL=updateFreightCostAndUnitFreightCost-5bef9a523a5d852fec2b.js.map