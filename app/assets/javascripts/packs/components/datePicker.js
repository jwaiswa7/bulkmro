const datePicker = () => {
    /*
    $('[data-toggle="datepicker"]').datepicker({
        format: 'dd-M-yyyy'
    });
    */

    $('[data-toggle="datepicker"]').daterangepicker({
        "singleDatePicker": true,
        opens: "left",
        locale: {
            format: 'DD-MMM-YYYY'
        }
    });
};

export default datePicker