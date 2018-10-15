const tinyHtmlEditor = () => {
    tinymce.init({
        selector: '.html-editor',
        plugins: "fullpage code autoresize",
        skin: 'lightgray',
        toolbar: 'undo redo | bold italic | link | code',
        menubar: false,
        fullpage_default_doctype: '<!DOCTYPE html>',
        fullpage_default_encoding: "UTF-8",
        visual : false
    });
};

// Pump and dump all DataTable set resources
let cleanUp = () => {
    tinymce.remove('.html-editor');
};

// Turbolinks hook
document.addEventListener("turbolinks:before-cache", function() {
    cleanUp();
});

export default tinyHtmlEditor