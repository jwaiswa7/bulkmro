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
/******/ 	return __webpack_require__(__webpack_require__.s = 25);
/******/ })
/************************************************************************/
/******/ ({

/***/ 25:
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
            var $errorWrapper = e.$element.siblings('.invalid-feedback');
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

    window.Parsley.on('form:validate', function (form) {
        if (!form.isValid()) {
            for (var n = 0; n < form.fields.length; n++) {
                if (form.fields[n].validationResult !== true) {
                    window.setTimeout(function () {
                        $('body').animate({
                            scrollTop: $(form.fields[n].$element[0]).offset().top + $('.navbar.navbar-expand-lg').height()
                        });
                    }, 0);
                    break;
                }
            }
        }
    });

    $("[data-parsley-validate]").parsley();
};

/* harmony default export */ __webpack_exports__["default"] = (parselyValidations);

/***/ })

/******/ });
//# sourceMappingURL=parselyValidations-73e3e1148904fa8c648a.js.map