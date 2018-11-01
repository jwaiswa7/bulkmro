// Component Imports
import customFileInputs from "./components/customFileInputs";
import select2s from "./components/select2s";
import tooltips from "./components/tooltips";
import textareaAutosize from "./components/textareaAutosize";
import nestedForms from "./components/nestedForms";
import googleAnalytics from "./components/googleAnalytics";
import parselyValidations from "./components/parselyValidations";
import dataTables from "./components/dataTables";
import loadViews from "./views/loadViews";
import alertsAutohide from "./components/alertsAutohide";
import tinyHtmlEditor from "./components/tinyHtmlEditor";
import chartjs from "./components/chartjs";
import datePicker from "./components/datePicker";
import stickyBits from "./components/stickyBits";
import daterangePicker from "./components/daterangePicker";
import notify from "./components/notify";

// Namespacing all imports under app
let app = {};

// Initaialize all components
app.initializeComponents = () => {
    customFileInputs();
    select2s();
    alertsAutohide();
    tooltips();
    textareaAutosize();
    nestedForms();
    googleAnalytics();
    parselyValidations();
    dataTables();
    tinyHtmlEditor();
    chartjs();
    datePicker();
    stickyBits();
    daterangePicker();
    notify();
};

// Turbolinks load event
document.addEventListener("turbolinks:load", function() {
    app.initializeComponents();

    // Load all views
    loadViews();
});