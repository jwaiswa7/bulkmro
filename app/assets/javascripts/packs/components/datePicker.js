const datePicker = () => {
    /*
    $('[data-toggle="datepicker"]').datepicker({
        format: 'dd-M-yyyy'
    });
    */
    $('body').on('click', '[data-toggle="datepicker"]', function() {
        $(this).daterangepicker({
            "singleDatePicker": true,
            opens: "left",
            locale: {
                format: 'DD-MMM-YYYY'
            }
        }).focus();
    });
};

export default datePicker