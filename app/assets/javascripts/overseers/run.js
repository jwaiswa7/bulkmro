$.fn.exists = function () {
    return jQuery(this).length > 0;
};

function dasherize(str) {
    return str.replace( /([a-z])([A-Z])/g, '$1-$2' ).toLowerCase();
}

function underscore(str) {
    return str.replace( /([a-z])([A-Z])/g, '$1_$2' ).toLowerCase();
}

