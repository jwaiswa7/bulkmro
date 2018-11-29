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
        onIsServiceChange(e.target)
    });
    $('body').on('click', 'button[name*=load-more-approved-alternatives]:button', function (e) {
        refreshPartial($(this).data("import-row-id"))
    });
};

let refreshPartial = (row_id) => {
    $.ajax({
        data: {import_row_id : row_id},
        url: "load_more_alternatives",
    })
}

let onRadioChange = (radio) => {
    let newProductForm = $(radio).closest('div.option-wrapper').find('div.nested');

    if (isNaN(radio.value)) {
        newProductForm.find(':input:visible:not(:radio)').prop('disabled', false).prop('required', true);
    } else {
        newProductForm.find(':input:visible:not(:radio)').prop('disabled', true).prop('required', false);
    }
};

let onIsServiceChange = (element) => {
    var tax_code_id = $(element).attr('id').replace("is_service","tax_code_id");
    $('#'+tax_code_id).val(null).trigger("change").attr('data-source', Routes.autocomplete_overseers_tax_codes_path({"is_service": $(element).val()})).select2('destroy');
    select2s();
};

export default manageFailedSkus