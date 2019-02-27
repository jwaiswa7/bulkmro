const hasher = () => {
    window.hasher = {
        getParam: function(param) {
            let string = this.getHashString();
            let url = new URL('https://dummy.bulkmro.com'); // A dummy url for using searchParams API
            url.search = string;
            return url.searchParams.get(param);
        },

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

        getHashString: function() {
            return window.location.hash.substr(2);
        },
    }
};

export default hasher