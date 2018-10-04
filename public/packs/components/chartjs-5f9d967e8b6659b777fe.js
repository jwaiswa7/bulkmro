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
/******/ 	return __webpack_require__(__webpack_require__.s = 28);
/******/ })
/************************************************************************/
/******/ ({

/***/ 28:
/*!************************************************************!*\
  !*** ./app/assets/javascripts/packs/components/chartjs.js ***!
  \************************************************************/
/*! exports provided: default */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
var globals = function globals() {
    Chart.defaults.global.hover.mode = 'nearest';
    // Chart.defaults.global.colors = ['#fd7e14', '#ffc107', '#dc3545', '#e83e8c'];
    Chart.defaults.global.defaultFontFamily = "'Muli', 'Helvetica Neue', 'Helvetica', 'Arial', sans-serif";
    Chart.defaults.global.defaultFontSize = 11;
};

var chartjs = function chartjs() {
    globals();
    barcharts();
};

var barcharts = function barcharts() {
    $(".chart-bar").each(function () {
        var label = $(this).data('label');
        var chartLabels = $(this).data('chart-labels');
        var chartData = $(this).data('chart-data');
        var datasets = [];

        chartData.foreach(function (val, index) {
            datasets[index] = [{
                label: label,
                data: chartData[index],
                fill: false,
                borderWidth: 1,
                backgroundColor: "rgba(255, 102, 0, 0.5)",
                borderColor: "rgba(255, 102, 0, 1)"
            }];
        });

        var chart = new Chart($(this)[0], {
            type: 'bar',
            data: {
                labels: chartLabels,
                datasets: datasets
            },
            options: {
                scales: {
                    yAxes: [{
                        ticks: {
                            beginAtZero: true
                        }
                    }]
                }
            }
        });
    });
};

/* harmony default export */ __webpack_exports__["default"] = (chartjs);

/***/ })

/******/ });
//# sourceMappingURL=chartjs-5f9d967e8b6659b777fe.js.map