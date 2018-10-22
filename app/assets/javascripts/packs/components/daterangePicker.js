const daterangePicker = () => {
    $('[data-toggle="daterangepicker"]').daterangepicker({
        opens: "left",
        locale: {
            format: 'DD-MMM-YYYY'
        }
    });
};

export default daterangePicker