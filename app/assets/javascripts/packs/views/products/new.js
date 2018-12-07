import select2s from "../../components/select2s";

const newAction = () => {
    onIsServiceChecked($("#"+$('input[name*=is_service]')[1].id).is("checked"));

    $('form').on('change', '[name*=is_service]', function (event) {
        //console.log($('input[name*=tax_code_id]'));
        $("#"+$('select[name*=tax_code_id]')[0].id).val(null).trigger("change");
        onIsServiceChecked(event.target.checked);
    })
};

let onIsServiceChecked = (is_service_status) => {
    $("#"+$('select[name*=tax_code_id]')[0].id).attr('data-source', Routes.autocomplete_overseers_tax_codes_path({"is_service": is_service_status})).select2('destroy');
    select2s();
}

export default newAction