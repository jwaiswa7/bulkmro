const removeHrefExport = () => {
    $('.export-button').click(function (event) {
        event.preventDefault();
        let url = $(this).attr('href');
        $(this).removeAttr('href');
        $(this).css('pointer-events','none');
        window.location.href = url
    });
};

export default removeHrefExport