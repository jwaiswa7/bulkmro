import easyAutocomplete from "../../components/easyAutocomplete";

const show = () => {
    easyAutocomplete('.global-search', createOptions('.global-search'))
};

const createOptions = (classname) => {
    let url = Routes.suggestion_overseers_inquiries_path
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


    };
    return options
}

export default show