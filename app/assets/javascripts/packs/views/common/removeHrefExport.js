const removeHrefExport = () => {
    $('.export-button').click(function (event) {
        $('.export-button').click(function (event) {
            $(this).removeAttr('href');
        });
    });
};

export default removeHrefExport