const daterangePicker = () => {
    $('body').on('click', '[data-toggle="daterangepicker"]', function() {
        $('[data-toggle="daterangepicker"]').daterangepicker({
            opens: "left",
            minDate: moment('2015-01-01'),
            maxDate: moment().endOf('year'),
            showDropdowns: true,
            locale: {
                format: 'DD-MMM-YYYY',
                "separator": " ~ ",
            }
        }).focus();
    });
};

export default daterangePicker