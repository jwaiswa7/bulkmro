import easyAutocomplete from "./easyAutocomplete";

const globalSearch = () => {
    easyAutocomplete('.global-search', createOptions('.global-search'))
    $('.global-search').on('click', function(){
        $('[data-toggle="tooltip"]').tooltip("hide");
        // gtag('event','click-search', { event_category: 'global-search',  event_label: 'Global search'})
    })
};

const createOptions = (classname) => {
    let url = Routes.suggestion_overseers_inquiries_path;
    let options = {
        url: function(phrase) {
            if (phrase !== "") {
                return url({prefix: phrase});
            } else {
                return url;
            }
        },

        listLocation: 'inquiries',

        getValue: 'text',

        template: {
            type: "links",
            fields: {
                link: "link"
            }
        },

        list: {
            maxNumberOfElements: 15,
            match: {
                enabled: true
            },
            sort: {
                enabled: false
            }
        },
        theme: "solid"
    };
    return options
}

export default  globalSearch