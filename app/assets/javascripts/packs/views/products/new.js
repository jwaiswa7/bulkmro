import select2s from "../../components/select2s";

const newAction = () => {
    $('form').on('change', '[name*=is_service]', function (event) {
        $("#product_tax_code_id").val(null).trigger("change");
        onIsServiceChecked(event.target);
    }).find('[name*=is_service]').each(function (element) {
        onIsServiceChecked(element);
    });


};

let onIsServiceChecked = (element) => {
    $('#product_tax_code_id').attr('data-source', Routes.autocomplete_overseers_tax_codes_path({"is_service": $(element).is(":checked")})).select2('destroy');
    select2s();
}

export default newAction