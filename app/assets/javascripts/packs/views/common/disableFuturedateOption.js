const disableFeaturedateOption = (element, autoUpdateInput = true) => {
    var datepickerOptions = {
        singleDatePicker: true,
        maxDate: moment(),
        autoUpdateInput: autoUpdateInput,
        locale: {
            format: 'DD-MMM-YYYY'
        }
    };
    element.daterangepicker(datepickerOptions)
}

export default disableFeaturedateOption