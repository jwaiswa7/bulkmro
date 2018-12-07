import select2s from "../../components/select2s";

const newAction = () => {
    if($("#product_is_service").is(":checked")){
        onIsServiceChecked($("#product_is_service").is(":checked"));
    }
    else{
        onIsServiceChecked($("#product_is_service").is(":checked"));
    }
    $('form').on('change', '[name*=is_service]', function (event) {
        $("#product_tax_code_id").val(null).trigger("change");
        onIsServiceChecked(event.target.checked);
    })
};

let onIsServiceChecked = (is_service_status) => {
    $('#product_tax_code_id').attr('data-source', Routes.autocomplete_overseers_tax_codes_path({"is_service": is_service_status})).select2('destroy');
    select2s();
};

export default newAction