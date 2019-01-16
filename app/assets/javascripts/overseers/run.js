Number.prototype.format = function(n, x) {
    let re = '\\d(?=(\\d{' + (x || 3) + '})+' + (n > 0 ? '\\.' : '$') + ')';
    return this.toFixed(Math.max(0, ~~n)).replace(new RegExp(re, 'g'), '$&,');
};

$.fn.exists = function () {
    return jQuery(this).length > 0;
};

$.fn.bindWithDelay = function (events, selector, data, handler, timeout, throttle) {
    // (evt, handler, timeout)
    if ($.isFunction(selector)) {
        throttle = handler;
        timeout = data;
        handler = selector;
        data = undefined;
        selector = undefined;
    }
    // (evt, selector, handler, timeout) OR (evt, data, handler, timeout)
    else if ($.isFunction(data)) {
        throttle = timeout;
        timeout = handler;
        handler = data;
        data = undefined;

        // (evt, data, handler, timeout)
        if (typeof selector !== "string") {
            data = selector;
            selector = undefined;
        }
    }

    // Allow delayed function to be removed with handler in unbind function
    handler.guid = handler.guid || ($.guid && $.guid++);

    // Bind each separately so that each element has its own delay
    return this.each(function () {
        let wait = null;

        function callback() {
            let event = $.extend(true, {}, arguments[0]);
            let that = this;
            let throttler = function () {
                wait = null;
                handler.apply(that, [event]);
            };

            if (!throttle) {
                clearTimeout(wait);
                wait = null;
            }
            if (!wait) {
                wait = setTimeout(throttler, timeout);
            }
        }

        callback.guid = handler.guid;
        $(this).on(events, selector, data, callback);
    });
};

function dasherize(str) {
    return str.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase();
}

function underscore(str) {
    return str.replace(/([a-z])([A-Z])/g, '$1_$2').toLowerCase();
}

function camelize(text) {
    let separator = arguments.length <= 1 || arguments[1] === undefined ? '_' : arguments[1];
    let words = text.split(separator);
    let camelized = [words[0]].concat(words.slice(1).map(function (word) {
        return '' + word.slice(0, 1).toUpperCase() + word.slice(1).toLowerCase();
    }));

    return camelized.join('');
}

function camelizeAndSkipLastWord(text) {
    let separator = arguments.length <= 1 || arguments[1] === undefined ? '_' : arguments[1];
    let words = text.split(separator);
    words.splice(words.length - 1, 1);
    let camelized = [words[0]].concat(words.slice(1).map(function (word) {
        return '' + word.slice(0, 1).toUpperCase() + word.slice(1).toLowerCase();
    }));

    return camelized.join('');
}
