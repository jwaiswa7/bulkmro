// Bootstrap overrides for default browser validation with Bootstrap's helper classes
const stepRoundUp = () => {
    $(document).ready(function () {
        $('[step]').bindWithDelay('keyup', function() {
            let value = $(this).val();
            let step = $(this).attr('step');
            if (step != 'any') {
                let rounded = Math.ceil(value/step)*step != 0 ? Math.ceil(value/step)*step : step;
                $(this).val(rounded);
            }
        }, 1500);
    });
};

export default stepRoundUp