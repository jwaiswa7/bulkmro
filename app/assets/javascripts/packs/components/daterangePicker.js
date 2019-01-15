const daterangePicker = () => {
    $('body').on('click', '[data-toggle="daterangepicker"]', function () {
        if (!$(this).data('daterangepicker')) {
            $('[data-toggle="daterangepicker"]').daterangepicker({
                ranges: {
                    'Today': [moment(), moment()],
                    'Yesterday': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
                    'Last 7 Days': [moment().subtract(6, 'days'), moment()],
                    'Last 30 Days': [moment().subtract(29, 'days'), moment()],
                    'This Month': [moment().startOf('month'), moment().endOf('month')],
                    'Last Month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')],
                    'Current Quarter': [moment().startOf('quarter'), moment().endOf('quarter')],
                    'Last Quarter': [moment().subtract(1, 'quarter').startOf('quarter'), moment().subtract(1, 'quarter').endOf('quarter')],
                },
                autoApply: true,
                opens: $(this).data('direction') ? $(this).data('direction') : "left",
                startDate: $(this).val() ? $(this).val() : moment().subtract(30, 'days'),
                minDate: moment('2015-01-01'),
                maxDate: moment().endOf('year'),
                showDropdowns: true,
                locale: {
                    format: 'DD-MMM-YYYY',
                    "separator": " ~ ",
                }
            }).focus();
        }
    });
};

export default daterangePicker