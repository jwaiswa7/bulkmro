const removeHrefExport = () => {
    $('.export-button').click(function (event) {
        event.preventDefault();
        let url = $(this).attr('href');
        $(this).removeAttr('href');
        $(this).addClass("export-disable");
        window.location.href = url
    });
};

export default removeHrefExport