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
/******/ 	return __webpack_require__(__webpack_require__.s = 4);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
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
            }
        });
    }).on('change', function () {
        $(this).trigger('input');
    });
};

/* harmony default export */ __webpack_exports__["default"] = (select2s);

/***/ }),
/* 2 */
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
/* 3 */
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
/* 4 */
/*!*****************************************************!*\
  !*** ./app/assets/javascripts/packs/application.js ***!
  \*****************************************************/
/*! no exports provided */
/*! all exports used */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__components_customFileInputs__ = __webpack_require__(/*! ./components/customFileInputs */ 0);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__components_select2s__ = __webpack_require__(/*! ./components/select2s */ 1);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2__components_tooltips__ = __webpack_require__(/*! ./components/tooltips */ 2);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3__components_textareaAutosize__ = __webpack_require__(/*! ./components/textareaAutosize */ 3);
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
};

// Turbolinks load event
document.addEventListener("turbolinks:load", function () {
    app.initializeComponents();
});

/***/ })
/******/ ]);
//# sourceMappingURL=application-14a8dc02b62f37d93b32.js.map