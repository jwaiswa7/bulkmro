const disableBackdateOption = (element, autoUpdateInput = true, minDate = moment()) => {
    var datepickerOptions = {
        singleDatePicker: true,
        minDate: minDate,
        autoUpdateInput: autoUpdateInput,
        locale: {
            format: 'DD-MMM-YYYY'
        }
    };
    element.daterangepicker(datepickerOptions)
}

export default disableBackdateOption