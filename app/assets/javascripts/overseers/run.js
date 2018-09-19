$.fn.exists = function () {
    return jQuery(this).length > 0;
};

function dasherize(str) {
    return str.replace( /([a-z])([A-Z])/g, '$1-$2' ).toLowerCase();
}

function underscore(str) {
    return str.replace( /([a-z])([A-Z])/g, '$1_$2' ).toLowerCase();
}

function camelize(text) {
    var separator = arguments.length <= 1 || arguments[1] === undefined ? '_' : arguments[1];
    var words = text.split(separator);
    var camelized = [words[0]].concat(words.slice(1).map(function (word) {
        return '' + word.slice(0, 1).toUpperCase() + word.slice(1).toLowerCase();
    }));

    return camelized.join('');
}