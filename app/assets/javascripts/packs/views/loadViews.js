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
import inwardDispatches from "./inwardDispatches/init";

// Sales Invoices
import salesInvoices from "./salesInvoices/init";

// Sales Shipments
import salesShipments from "./salesShipments/init";

// Purchase Orders
import purchaseOrders from "./purchaseOrders/init";

// Payment Requests
import paymentRequests from "./paymentRequests/init";

// Invoice Requests
import invoiceRequests from "./invoiceRequests/init";

// Po Requests
import poRequests from "./poRequests/init";

// AR invoices
import arInvoiceRequests from "./arInvoiceRequests/init";
import packingSlips from "./packingSlips/init";

// Activities
import activities from './activities/init'

import companies from './companies/init'
import suppliers from  './suppliers/init'

import companyReviews from './companyReviews/init'

// Document Creation
import documentCreations from "./documentCreations/init";

import checkout from "./checkout/init";

// Image Reader
import imageReaders from "./imageReaders/init"

import taxCodes from "./taxCodes/init"

import companyBanks from "./companyBanks/init"

// Dashboard
import dashboard from "./dashboard/init"

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
    inwardDispatches: inwardDispatches,
    salesInvoices: salesInvoices,
    salesShipments: salesShipments,
    purchaseOrders: purchaseOrders,
    paymentRequests: paymentRequests,
    invoiceRequests: invoiceRequests,
    poRequests: poRequests,
    activities: activities,
    companies: companies,
    suppliers: suppliers,
    companyReviews: companyReviews,
    documentCreations: documentCreations,
    checkout: checkout,
    taxCodes: taxCodes,
    imageReaders: imageReaders,
    companyBanks: companyBanks,
    arInvoiceRequests: arInvoiceRequests,
    dashboard: dashboard,
    packingSlips:packingSlips
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
