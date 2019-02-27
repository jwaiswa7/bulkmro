const hasher = () => {
    window.hasher = {
        // This gets a URL hash parameter using a key
        getParam: function(param) {
            let string = this.getHashString();
            let url = new URL('https://dummy.bulkmro.com'); // A dummy url for using searchParams API
            url.search = string;
            return url.searchParams.get(param) ? url.searchParams.get(param) : "";
        },

        // This sets a parameter in the URL hash using a key/value pair
        setParam: function(param, value) {
            let string = this.getHashString();
            let url = new URL('https://dummy.bulkmro.com'); // A dummy url for using searchParams API
            url.search = string;

            if (value) {
                url.searchParams.set(param, value);
            } else {
                url.searchParams.delete(param);
            }

            window.location.hash = ['!', url.search.substring(1)].join('');
        },

        // Generic function to see if there are any URL hashes defined, skips the '#!' from the return string
        getHashString: function() {
            return window.location.hash.substr(2);
        },
    }
};

export default hasher