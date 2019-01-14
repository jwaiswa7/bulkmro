import select2s from "../../components/select2s";

const newAction = () => {

    $('form').on('change', 'select[name*=delivery_type]', function (e) {
        let reset = true;
        onDeliveryTypeChange(this, reset);
    }).find('select[name*=delivery_type]').each(function (e) {
        let reset = false;
        onDeliveryTypeChange(this, reset);
    });

    $('form').on('change', 'select[name*=supplier_id]', function (e) {
        let reset = true;
        onSupplierChange(this, reset);
    }).find('select[name*=supplier_id]').each(function (e) {
        let reset = false;
        onSupplierChange(this, reset);
    });

    $('.calculate-metric').on('keyup', function (e) {
        calculateVolumetricWeight()
    });

    $('#freight_request_measurement').on('change', function (e) {
        calculateVolumetricWeight();
    });
};

let onSupplierChange = (container, reset) => {
    let optionSelected = $("option:selected", container);
    if (optionSelected.exists() && optionSelected.val() !== '') {
        if (reset) {
            $("#freight_request_pick_up_address_id").val(null).trigger("change");
        }
        $('#freight_request_pick_up_address_id').attr('data-source', Routes.autocomplete_overseers_company_addresses_path(optionSelected.val())).select2('destroy');

        select2s();
    }
};

let onDeliveryTypeChange = (container, reset) => {
    let optionSelected = $("option:selected", container);
    if (optionSelected.exists() && optionSelected.val() !== '') {
        /*if (reset) {
            $("#freight_request_delivery_address_id").val(null).trigger("change");
        }*/
        console.log(optionSelected.val());
        if(optionSelected.val() == 'Regular') {
            $('#freight_request_delivery_address_id').attr('data-source', Routes. warehouse_addresses_overseers_addresses_path()).select2('destroy');
        }
        else{
            $('#freight_request_delivery_address_id').attr('data-source', Routes.autocomplete_overseers_company_addresses_path($('#freight_request_company_id').val())).select2('destroy');
        }

        select2s();
    }
};

let calculateVolumetricWeight = () => {
    let volumetricWeight = 1;
    $(".calculate-metric").each(function () {
        if($(this).val() != '' && parseFloat($(this).val()) > 0){
            volumetricWeight = volumetricWeight * parseFloat($(this).val());
        }
    });

    if ($('#freight_request_measurement').val() == "CM") {
        volumetricWeight = volumetricWeight / 6000;
    } else {
        volumetricWeight = volumetricWeight / 366;
    }
    $('#freight_request_volumetric_weight').val(parseFloat(volumetricWeight).toFixed(2));
};

export default newAction