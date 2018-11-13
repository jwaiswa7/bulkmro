$.fn.exists = function () {
    return jQuery(this).length > 0;
};

$.fn.bindWithDelay = function( type, data, fn, timeout, throttle ) {
    if ( $.isFunction( data ) ) {
        throttle = timeout;
        timeout = fn;
        fn = data;
        data = undefined;
    }

    // Allow delayed function to be removed with fn in unbind function
    fn.guid = fn.guid || ($.guid && $.guid++);

    // Bind each separately so that each element has its own delay
    return this.each(function() {

        var wait = null;

        function cb() {
            var e = $.extend(true, { }, arguments[0]);
            var ctx = this;
            var throttler = function() {
                wait = null;
                fn.apply(ctx, [e]);
            };

            if (!throttle) { clearTimeout(wait); wait = null; }
            if (!wait) { wait = setTimeout(throttler, timeout); }
        }

        cb.guid = fn.guid;
        $(this).bind(type, data, cb);
    });
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

function camelizeAndSkipLastWord(text) {
    var separator = arguments.length <= 1 || arguments[1] === undefined ? '_' : arguments[1];
    var words = text.split(separator);
    words.splice(words.length-1,1);
    var camelized = [words[0]].concat(words.slice(1).map(function (word) {
        return '' + word.slice(0, 1).toUpperCase() + word.slice(1).toLowerCase();
    }));

    return camelized.join('');
}

function searchsubmit(val){
    $.ajax({
        url: self.location.href.split('?')[0],
        data: {q: val},
        beforeSend: function(){
            $("#grid_container").addClass("blur");
        },
        success: function(x) {
            var pro_ind = $("#products_index", x).html();
            $("#products_index").html(pro_ind);
        },
        complete:function(){
            $("#grid_container").removeClass("blur");
        }
    })
}
