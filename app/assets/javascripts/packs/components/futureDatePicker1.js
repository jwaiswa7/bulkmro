const futureDatePicker1 = () => {
    $('body').on('click', '[data-toggle="futureDatePicker1"]', function() {
        const today = new Date();
        let tomorrow =  new Date()
        tomorrow.setDate(today.getDate() + 1)
        if (!$(this).data('daterangepicker')) {
            $(this).daterangepicker({
                singleDatePicker: true,
                showDropdowns: true,
                minDate: tomorrow,
                opens: $(this).data('direction') ? $(this).data('direction') : "left",
                locale: {
                    format: 'DD-MMM-YYYY'
                }
            }).focus();
        }
    });
};

export default futureDatePicker1