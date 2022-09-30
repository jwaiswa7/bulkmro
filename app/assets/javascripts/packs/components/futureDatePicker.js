const futureDatePicker = () => {
    $('body').on('click', '[data-toggle="futureDatePicker"]', function() {
        const date = new Date();
        if (!$(this).data('daterangepicker')) {
            $(this).daterangepicker({
                singlefutureDatePicker: true,
                showDropdowns: true,
                minDate: date,
                opens: $(this).data('direction') ? $(this).data('direction') : "left",
                locale: {
                    format: 'DD-MMM-YYYY'
                }
            }).focus();
        }
    });
};

export default futureDatePicker