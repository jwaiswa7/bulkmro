// Export with date range
const exportDaterange = () => {
    $('#export_daterange').on('change', function() {
        var url =$('#export_daterange_button').attr('href');
        var arr = url.split('?');
        $("#export_daterange_button").attr("href", arr[0]+"?q="+encodeURIComponent($(this).val()));
    })
};

export default exportDaterange