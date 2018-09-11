// Makes sure that the custom file inputs have the highlighted border on file selection
const customFileInputs = () => {
    $('.custom-file-input').on('change', function () {
        $(this).next('.custom-file-label').addClass("selected").html($(this).val().split('\\').slice(-1)[0]);
    })
};

export default customFileInputs