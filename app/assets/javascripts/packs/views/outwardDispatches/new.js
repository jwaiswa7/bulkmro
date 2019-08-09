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
    })
    $('.packing_slip_wrapper').on('change',"#packing_slips input[name*='box_number']",function () {
    // $("#packing_slips input[name*='box_number']").on('change', function() {
        //Create array of input values
        console.log($("#packing_slips input[name*='box_number']"))

        var ar = $("#packing_slips input[name*='box_number']").map(function() {
            if ($(this).val() != '') return $(this).val()
        }).get();
        console.log(ar)
        //Create array of duplicates if there are any
        var unique = ar.filter(function(item, pos) {
            return ar.indexOf(item) != pos;
        });

        //show/hide error msg
        (unique.length != 0) ? $('.error').text('duplicate'): $('.error').text('');
    })


}

export default outwardNew