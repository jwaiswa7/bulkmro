const BibleUploadLogShow = () => {
    $(function(){
        $('#BibleRowModal').modal({
            keyboard: true,
            backdrop: "static",
            show:false,
        }).on('show', function(){
        });
    });

    $('.sheet-view-data').on('click', function () {
        var rowData = $(this).siblings('.sheet-row-data').text()
        $('#bible-row-data').html($('<p>' + rowData  + '</p>'))
        $('#BibleRowModal').modal('show');
    });
};

export default BibleUploadLogShow