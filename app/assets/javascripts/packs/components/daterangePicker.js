const daterangePicker = () => {
    $('body').on('click', '[data-toggle="daterangepicker"]', function() {
        $('[data-toggle="daterangepicker"]').daterangepicker({
            opens: "left",
            locale: {
                format: 'DD-MMM-YYYY',
                "separator": " ~ ",
            }
        }).focus();
    });
};

export default daterangePicker