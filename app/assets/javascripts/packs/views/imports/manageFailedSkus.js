import select2s from "../../components/select2s";

const manageFailedSkus = () => {
    var page = 1;
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
    $('body').on('click', 'button[name*=load-previous-approved-alternatives]:button', function (e) {
        if(--page < 1){
            $(this).addClass('disabled');
        }else{
            $(this).removeClass('disabled');
            showPrevious($(this).data("row-object"), --page);
        }
    });
    $('body').on('click', 'button[name*=load-next-approved-alternatives]:button', function (e) {
        showNext($(this).data("row-object"), ++page);
    });
};

let showPrevious = (row_object, page) => {
    $.ajax({
        data: {row_object : row_object, page: page},
        url: "load_alternatives",
    })
}

let showNext = (row_object, page) => {
    $.ajax({
        data: {row_object : row_object, page: page},
        url: "load_alternatives",
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