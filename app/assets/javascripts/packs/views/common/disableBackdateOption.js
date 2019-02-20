const disableBackdateOption = (e) => {
    var datepickerOptions = {
        singleDatePicker: true,
        minDate: moment(),
        locale: {
            format: 'DD-MMM-YYYY'
        }
    };
    e.daterangepicker(datepickerOptions)
}

export default disableBackdateOption