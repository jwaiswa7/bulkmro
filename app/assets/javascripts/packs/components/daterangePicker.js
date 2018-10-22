const daterangePicker = () => {
    $('body').on('click', '[data-toggle="daterangepicker"]', function() {
        $('[data-toggle="daterangepicker"]').daterangepicker({
            opens: "left",
            locale: {
                format: 'DD-MMM-YYYY'
            }
        }).focus();
    });
};

export default daterangePicker