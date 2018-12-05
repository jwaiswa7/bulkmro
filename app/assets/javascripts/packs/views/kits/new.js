import select2s from "../../components/select2s";

const newAction = () => {

    if($("#kit_product_attributes_is_service").is(":checked")){
        onIsServiceChecked($("#kit_product_attributes_is_service").is(":checked"));
    }
    else{
        onIsServiceChecked($("#kit_product_attributes_is_service").is(":checked"));
    }
    $('form').on('change', '[name*=is_service]', function (event) {
        $("#kit_product_attributes_tax_code_id").val(null).trigger("change");
        onIsServiceChecked(event.target.checked);
    })


};

let onIsServiceChecked = (is_service_status) => {
    $('#kit_product_attributes_tax_code_id').attr('data-source', Routes.autocomplete_overseers_tax_codes_path({"is_service": is_service_status})).select2('destroy');
    select2s();
}

export default newAction