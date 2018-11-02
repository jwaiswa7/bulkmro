import select2s from "../../components/select2s";

const manageFailedSkus = () => {
    $(':input:visible:radio:checked').each(function (e) {
        onRadioChange(this);
    });

    $('body').on('cocoon:after-remove', function (e, removedItem) {
        $(removedItem).each(function (index, item) {
            $(item).find(':input:not(:radio):not([type=hidden]),textarea').prop('disabled', true).prop('required', false);

        });
    });
    $('body').on('change', 'input[name*=approved_alternative_id]:radio', function (e) {
        onRadioChange(this);
    });
    $('body').on('change','select[id*=inquiry_product_attributes_product_attributes_is_service]',function(e){
        onIsSelectChange(this)
    });
};

let onRadioChange = (radio) => {
    let newProductForm = $(radio).closest('div.option-wrapper').find('div.nested');

    if (isNaN(radio.value)) {
        newProductForm.find(':input:visible:not(:radio)').prop('disabled', false).prop('required', true);
    } else {
        newProductForm.find(':input:visible:not(:radio)').prop('disabled', true).prop('required', false);
    }
};

let onIsSelectChange = (event) => {
    var common_id_text = $(event).attr('id').replace("_inquiry_product_attributes_product_attributes_is_service","");
    var is_service_val = $(event).val();
    var tax_code_id = common_id_text+'_inquiry_product_attributes_product_attributes_tax_code_id';
    $('#'+tax_code_id).val(null).trigger("change");
    $('#'+tax_code_id).attr('data-source', Routes.autocomplete_overseers_tax_codes_path({"is_service": is_service_val})).select2('destroy');
    select2s();
};

export default manageFailedSkus