// Component Imports
import importsCreateFailedSkus from "./imports/createFailedSkus";
import importsManageFailedSkus from "./imports/manageFailedSkus";

import inquiriesEdit from "./inquiries/edit";
import inquiriesEditSuppliers from "./inquiries/edit";
import inquiriesUpdateSuppliers from "./inquiries/edit";

let loader = {
    imports: {
        createFailedSkus: importsCreateFailedSkus,
        manageFailedSkus: importsManageFailedSkus
    },

    inquiries: {
        edit: inquiriesEdit,
        editSuppliers: inquiriesEditSuppliers,
        updateSuppliers: inquiriesUpdateSuppliers,
    },
};

// Imports
/*
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

        console.log(r(key).default.name);
        console.log(r(key).default);
        loader[controller][view.name] = r(key).default;
    });
};
importAll(require.context('./', true, /\.js$/));
*/

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

export default loadViews