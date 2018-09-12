// Component Imports
import select2s from "./select2s";

// Handles dynamic additions of fields to nested forms
const nestedForms = () => {
    $('body')
        .on("fields_added.nested_form_fields", function (e, param) {
            select2s();
        })
        .on("fields_removed.nested_form_fields", function (e, param) {
            select2s();
        });
};

export default nestedForms