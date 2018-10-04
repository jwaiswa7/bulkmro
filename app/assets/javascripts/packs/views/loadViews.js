// Component Imports

//
// Imports
import importsCreateFailedSkus from "./imports/createFailedSkus";
import importsManageFailedSkus from "./imports/manageFailedSkus";

//
// Inquiries
import inquiriesEdit from "./inquiries/edit";
import inquiriesEditSuppliers from "./inquiries/edit";
import inquiriesUpdateSuppliers from "./inquiries/edit";

//
// Products
import productsEdit from "./products/edit";
import productsNew from "./products/new";

//
// Sales Orders
import salesOrdersCreate from "./salesOrders/create";
import salesOrdersEdit from "./salesOrders/edit";
import salesOrdersNew from "./salesOrders/new";
import salesOrdersNewRevision from "./salesOrders/newRevision";
import salesOrdersUpdate from "./salesOrders/update";
import salesOrdersUpdateOnSelect from "./salesOrders/updateOnSelect";

//
// Sales Quotes
import salesQuotesCreate from "./salesQuotes/create";
import salesQuotesEdit from "./salesQuotes/edit";
import salesQuotesNew from "./salesQuotes/new";
import salesQuotesNewRevision from "./salesQuotes/newRevision";
import salesQuotesUpdate from "./salesQuotes/update";


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

    products: {
        edit: productsEdit,
        new: productsNew
    },

    salesOrders: {
        create: salesOrdersCreate,
        edit: salesOrdersEdit,
        new: salesOrdersNew,
        newRevision: salesOrdersNewRevision,
        update: salesOrdersUpdate,
        updateOnSelect: salesOrdersUpdateOnSelect
    },

    salesQuotes: {
        create: salesQuotesCreate,
        edit: salesQuotesEdit,
        new: salesQuotesNew,
        newRevision: salesQuotesNewRevision,
        update: salesQuotesUpdate
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
    console.log(loader);

    if (controller in loader && controllerAction in loader[controller]) {
        loader[controller][controllerAction]();
        console.log("loader[" + controller + "][" + controllerAction + "]")
    } else if (controller in loader && controllerAction + 'Action' in loader[controller]) {
        loader[controller][controllerAction + 'Action']();
        console.log("loader[" + controller + "][" + controllerAction + "]")
    }
};

export default loadViews