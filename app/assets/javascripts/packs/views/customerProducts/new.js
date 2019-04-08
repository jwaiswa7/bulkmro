import select2s from "../../components/select2s";

const newAction = () => {
    $('form').on('change', 'select[name*=product_id]', function (e) {
        let reset = true;
        onProductChange($(this).val());
    }).find('select[name*=product_id]').each(function (e) {
        let reset = false;
        onProductChange($(this).val());
    });

};

let onProductChange = (product_id) => {
    $('#customer_product_tax_code_id').attr('data-source', Routes.autocomplete_for_product_overseers_tax_codes_path({"product_id": product_id})).select2('destroy');
    select2s();
};

export default newAction