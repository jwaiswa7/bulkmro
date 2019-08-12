import disableFeuredateOption from "../common/disableFuturedateOption";
import disableBackdateOption from "../common/disableBackdateOption";

const outwardNew = () => {
    $('[name="outward_dispatch[material_dispatch_date]"]').on("focus", function () {
        disableFeuredateOption($('[name="outward_dispatch[material_dispatch_date]"]'));
    });
    $('[name="outward_dispatch[material_delivery_date]').on("focus", function () {
        disableFeuredateOption($('[name="outward_dispatch[material_delivery_date]'));
    });
    $('[name="outward_dispatch[expected_date_of_delivery]').on("focus", function () {
        var newDate = Date.parse($('[name="outward_dispatch[material_dispatch_date]').val())
        disableBackdateOption($('[name="outward_dispatch[expected_date_of_delivery]'),true,moment(newDate).format('DD-MMM-YYYY'));
    });

    $('.material_delivery_date .clear-date').unbind('click').bind('click', function () {
        $('[name="outward_dispatch[material_delivery_date]').val('')
    });

    if($('#outward_dispatch_logistics_partner').val() == "Others"){
        $('.other-logistics-partner').removeClass('d-none');
    }

    $('select[name*=logistics_partner]').unbind().bind('change', function () {
        if ($(this).val() == "Others") {
            $('.other-logistics-partner').removeClass('d-none');
            $('.other-logistics-partner').find('input').attr("required", true);
        }
        else {
            $('.other-logistics-partner').addClass('d-none');
            $('.other-logistics-partner').find('input').val('').attr("required", false);
        }
    });
};

export default outwardNew