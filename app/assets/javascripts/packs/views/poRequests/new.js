import updateRowTotal from "./updateRowTotal"
import select2s from "../../components/select2s";


const newAction = () => {

    $('form').on('change', 'select[name*=product_id]', function (e) {
        onProductChange(this);
    }).find('select[name*=product_id]').each(function (e) {
        onProductChange(this);
    });
    $('form').on('change', 'select[name*=supplier_id]', function (e) {
        let reset = true;
        onSupplierChange(this, reset);
    }).find('select[name*=supplier_id]').each(function (e) {
        let reset = false;
        onSupplierChange(this, reset);
    });

    $('form').on('change', 'select[name*=contact_id]', function (e) {
        let reset = true;
        onContactChange(this, reset);
    }).find('select[name*=contact_id]').each(function (e) {
        let reset = false;
        onContactChange(this, reset);
    });
    updateRowTotal();

}

let onProductChange = (container) => {
    let optionSelected = $("option:selected", container);
    let row = $(container).closest('.po-request-row');
    if (optionSelected.exists() && optionSelected.val() !== '') {
        $.getJSON({
            url: Routes.get_product_details_overseers_product_path(optionSelected.val()),

            success: function (response) {
                row.find('[name*=brand]').val(response.brand);
                row.find('[name*=tax_rate_id]').val(response.tax_rate_id).trigger("change");
                row.find('[name*=measurement_unit]').val(response.measurement_unit);
                row.find('[name*=unit_price]').val(response.converted_unit_selling_price);
            }
        });
    }
};

let onSupplierChange = (container, reset) => {
    let optionSelected = $("option:selected", container);
    if (optionSelected.exists() && optionSelected.val() !== '') {
        if (reset) {
            $('form').find('select[name*=bill_from_id]').val(null).trigger("change");
            $('form').find('select[name*=ship_from_id]').val(null).trigger("change");
            // $('form').find('select[name*=contact_id]').val(null).trigger("change");
        }
        $('form').find('select[name*=bill_from_id]').attr('data-source', Routes.autocomplete_overseers_company_addresses_path(optionSelected.val())).select2('destroy');
        $('form').find('select[name*=ship_from_id]').attr('data-source', Routes.autocomplete_overseers_company_addresses_path(optionSelected.val())).select2('destroy');
        $('form').find('select[name*=contact_id]').attr('data-source', Routes.autocomplete_overseers_company_contacts_path(optionSelected.val()));
        selectContact(optionSelected.val(),'company')
        select2s();
    }
};

let selectContact = (company_id,attribute) => {
    console.log('attribute:- '+attribute)
    $.ajax({
        url: Routes.get_contacts_overseers_companies_path(),
        data: {attribute_id: company_id, attribute: attribute},
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function success(data) {
            if(attribute =='company'){
                var option = new Option(data.contact_name, data.contact_id, true, true);
                $('form').find('select[name*=contact_id]').append(option)
            }
            if(data.contact_email){
                $('form').find('input[name*=contact_email]').val(data.contact_email).trigger('change');
            }else{
                $('form').find('input[name*=contact_email]').val('').trigger('change');
            }
            if(data.contact_mobile){
                $('form').find('input[name*=contact_phone]').val(data.contact_mobile).trigger('change');
            }else{
                $('form').find('input[name*=contact_phone]').val('').trigger('change');
            }
        },
    })
};


let onContactChange = (container, reset) => {
    let optionSelected = $("option:selected", container);
    if (optionSelected.exists() && optionSelected.val() !== '') {
        selectContact(optionSelected.val(),'contact')
        select2s();
    }
};

export default newAction