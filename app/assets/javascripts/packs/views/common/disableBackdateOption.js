const disableBackdateOption = (element) => {
    var datepickerOptions = {
        singleDatePicker: true,
        minDate: moment(),
        locale: {
            format: 'DD-MMM-YYYY'
        }
    };
    element.daterangepicker(datepickerOptions)
}

export default disableBackdateOption