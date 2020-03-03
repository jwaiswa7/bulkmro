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

    $('.packing_slip_wrapper').on('change',"#packing_slips input[name*='box_number']",function () {
        var ar = $("#packing_slips input[name*='box_number']").map(function() {
            if ($(this).val() != '') return $(this).val()
        }).get();
        ar = ar.map(Number)
        //Create array of duplicates if there are any
        var unique = ar.filter(function(item, pos) {
            return ar.indexOf(item) != pos;
        });

        //show/hide error msg
        (unique.length != 0) ? $('.error').text('Please check you have entered duplicate box number.'): $('.error').text('');
        if( $('.error').is(':empty'))
        {
            $(".submit-form").attr("disabled", false);
        }
        else {
            $(".submit-form").attr("disabled", true);
        }
    });

    $('select[name*=logistics_partner]').bind('change', function () {
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