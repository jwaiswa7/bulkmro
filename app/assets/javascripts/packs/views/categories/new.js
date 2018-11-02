import select2s from "../../components/select2s";

const newAction = () => {
    if($("#category_is_service").attr('checked')){
        onIsServiceChecked($("#category_is_service").is(":checked"));
    }
    $('form').on('change', '[name*=is_service]', function (event) {
        $("#category_tax_code_id").val(null).trigger("change");
        onIsServiceChecked(event.target.checked);
    })
};

let onIsServiceChecked = (element) => {
    $('#category_tax_code_id').attr('data-source', Routes.autocomplete_overseers_tax_codes_path({"is_service": element})).select2('destroy');
    select2s();
}

export default newAction