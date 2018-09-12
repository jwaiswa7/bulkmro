// Imports
let loader = {};
let importAll = (r) => {
    r.keys().forEach(key => {
        // Remove any files under the /views directory
        if (key.split('/')[1].includes('.js')) return;

        // Get the controller name
        let controller = key.split('/')[1];

        // Get the function
        let view = r(key).default;

        // Set the functions relative to the controllers
        loader[controller] = loader[controller] ? loader[controller] : {};
        loader[controller][view.name] = r(key).default;
    });
};
importAll(require.context('./', true, /\.js$/));

const loadViews = () => {
    let dataAttributes = $('body').data();
    let controller = camelize(dataAttributes.controller);
    let controllerAction = camelize(dataAttributes.controllerAction);

    if (controller in loader && controllerAction in loader[controller]) {
        loader[controller][controllerAction]();
        console.log("loader[" + controller + "][" + controllerAction + "]")
    } else if (controller in loader && controllerAction + 'Action' in loader[controller]) {
        loader[controller][controllerAction + 'Action']();
        console.log("loader[" + controller + "][" + controllerAction + "]")
    }
};

let camelize = function(text) {
    let separator = arguments.length <= 1 || arguments[1] === undefined ? '_' : arguments[1];
    let words = text.split(separator);
    let camelized = [words[0]].concat(words.slice(1).map(function (word) {
        return '' + word.slice(0, 1).toUpperCase() + word.slice(1).toLowerCase();
    }));

    console.log(camelized);

    return camelized.join('');
};

export default loadViews