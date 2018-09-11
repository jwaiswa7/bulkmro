/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import customFileInputs from "./components/customFileInputs";
import select2s from "./components/select2s";
import tooltips from "./components/tooltips";

// Namespacing all imports under app
let app = {};

// Initaialize all components
app.initializeComponents = () => {
    customFileInputs();
    select2s();
    tooltips();
};

// Turbolinks load event
document.addEventListener("turbolinks:load", function() {
    app.initializeComponents();
});