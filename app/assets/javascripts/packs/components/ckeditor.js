const ckeditor = () => {
    InlineEditor
        .create(document.querySelector('.html-editor'))
        .then(editor => {
            console.log(editor);
        })
        .catch(error => {
            console.error(error);
        });
};

export default ckeditor