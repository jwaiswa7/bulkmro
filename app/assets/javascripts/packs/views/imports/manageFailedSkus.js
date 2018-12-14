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
    $('body').on('click', 'button[name*=load-previous-approved-alternatives]:button', function (e) {
        var page = $(this).parent().attr('data-page');
        if(page > 1){
            showPrevious($(this).data("row-object"), --page, $(this).parent().data("index"));
        }
        if(page < 2){
            $(this).addClass('disabled');
        }
    });
    $('body').on('click', 'button[name*=load-next-approved-alternatives]:button', function (e) {
        var page = $(this).parent().attr('data-page');
        showNext($(this).data("row-object"), ++page, $(this).parent().data("index"));
        if(page > 1){
            $(this).siblings().removeClass('disabled');
        }
    });
};

let showPrevious = (row_object, page, index) => {
    $.ajax({
        data: {row_object : row_object, page: page, index:index},
        url: "load_alternatives",
    })
};

let showNext = (row_object, page, index) => {
    $.ajax({
        data: {row_object : row_object, page: page, index:index},
        url: "load_alternatives",
    })
};

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