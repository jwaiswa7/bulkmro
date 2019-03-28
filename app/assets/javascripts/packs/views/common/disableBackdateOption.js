const disableBackdateOption = (element, autoUpdateInput = true) => {
    var datepickerOptions = {
        singleDatePicker: true,
        minDate: moment(),
        autoUpdateInput: autoUpdateInput,
        locale: {
            format: 'DD-MMM-YYYY'
        }
    };
    element.daterangepicker(datepickerOptions)
}

export default disableBackdateOption