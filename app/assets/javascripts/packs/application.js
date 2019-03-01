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
import datePicker from "./components/datePicker";
import stickyBits from "./components/stickyBits";
import daterangePicker from "./components/daterangePicker";
import notify from "./components/notify";
import stepRoundUp from "./components/stepRoundUp";
import dropdowns from "./components/dropdownSubmenus";
import chartjs from "./components/chartjs";
import highlightjs from "./components/highlightjs";
import lazyLoadImages from "./components/lazyLoadImages";
import tableHighlightWholly from "./components/tableHighlightWholly";
import hasher from "./components/hasher";
import notifications from "./components/notifications";

// Namespacing all imports under app
let app = {};

// Initaialize all components
app.initializeComponents = () => {
    hasher();
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
    datePicker();
    stickyBits();
    daterangePicker();
    notify();
    stepRoundUp();
    dropdowns();
    chartjs();
    lazyLoadImages();
    highlightjs();
    tableHighlightWholly();
    notifications();
};

// Turbolinks load event
document.addEventListener("turbolinks:load", function() {
    app.initializeComponents();

    // Load all views
    loadViews();
});