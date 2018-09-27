const tinyHtmlEditor = () => {
    tinymce.init({
        selector: '.html-editor',
        plugins: "fullpage code",
        skin: 'lightgray',
        toolbar: 'undo redo | bold italic | link | code',
        menubar: false,
        fullpage_default_doctype: '<!DOCTYPE html>',
        fullpage_default_encoding: "UTF-8",
        visual : false
    });
};

export default tinyHtmlEditor