const datePicker = () => {
    $('body').on('click', '[data-toggle="datepicker"]', function() {
        if (!$(this).data('daterangepicker')) {
            $(this).daterangepicker({
                singleDatePicker: true,
                showDropdowns: true,
                opens: "left",
                locale: {
                    format: 'DD-MMM-YYYY'
                }
            }).focus();
        }
    });
};

export default datePicker