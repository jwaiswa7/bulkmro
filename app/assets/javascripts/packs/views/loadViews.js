// Component Imports

//
// Imports
import imports from './imports/init'

//
// Inquiries
import inquiries from './inquiries/init'

//
// Products
import products from "./products/init";
//
// Sales Orders
import salesOrders from "./salesOrders/init";

// Reports
import reports from './reports/init';

//
// Sales Quotes
import salesQuotes from "./salesQuotes/init";

import categories from "./categories/init";
import customerProducts from "./customerProducts/init";
import kits from "./kits/init";
import freightRequests from "./freightRequests/init";
import freightQuotes from "./freightQuotes/init";

// Sales Invoices
import salesInvoices from "./salesInvoices/init";

// Sales Shipments
import salesShipments from "./salesShipments/init";

// Purchase Orders
import purchaseOrders from "./purchaseOrders/init";

// Payment Requests
import paymentRequests from "./paymentRequests/init";

// Invoice Requests
import invoiceRequests from "./paymentRequests/init";

// Po Requests
import poRequests from "./poRequests/init";

// Activities
import activities from './activities/init'

import companies from './companies/init'

let loader = {
    imports: imports,
    reports: reports,
    inquiries: inquiries,
    products: products,
    salesOrders: salesOrders,
    categories: categories,
    salesQuotes: salesQuotes,
    customerProducts: customerProducts,
    kits: kits,
    freightRequests: freightRequests,
    freightQuotes: freightQuotes,
    salesInvoices: salesInvoices,
    salesShipments: salesShipments,
    purchaseOrders: purchaseOrders,
    paymentRequests: paymentRequests,
    invoiceRequests: invoiceRequests,
    poRequests: poRequests,
    activities: activities,
    companies: companies
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