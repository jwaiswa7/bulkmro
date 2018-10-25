import select2s from "../../components/select2s";

const newAction = () => {

    $('form').on('change', 'select[name*=shipping_company_id]', function (e) {
        onShippingCompanyChange(this);
    })/*.find('select[name*=shipping_company_id]').each(function (e) {
        onShippingCompanyChange(this);
    })*/;


};

let onShippingCompanyChange = (container) => {
    let optionSelected = $("option:selected", container);

    if (optionSelected.exists() && optionSelected.val() !== '') {

        $('#inquiry_shipping_address_id').attr('data-source', Routes.autocomplete_overseers_company_addresses_path(optionSelected.val())).select2('destroy')
        $('#inquiry_shipping_contact_id').attr('data-source', Routes.autocomplete_overseers_company_contacts_path(optionSelected.val())).select2('destroy')
        select2s();
    }
};


export default newAction