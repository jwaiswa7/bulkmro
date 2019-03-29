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
            showPaginationButton($(this).data("row-object"), page, $(this).parent().data("index"), "previous");
        }
        if(--page < 2){
            $(this).addClass('disabled');
        }
    });
    $('body').on('click', 'button[name*=load-next-approved-alternatives]:button', function (e) {
        var page = $(this).parent().attr('data-page');
        showPaginationButton($(this).data("row-object"), page, $(this).parent().data("index"), "next");
        if(++page > 1){
            $(this).siblings().removeClass('disabled');
        }
    });
};

let showPaginationButton = (row_object, page, index, action) => {
    page = action == "previous" ? --page : ++page;
    $.ajax({
        data: {row_object : row_object, page: page, index:index},
        url: "load_alternatives",
        success: function (data) {
            console.log(data);
            $('.' + row_object + '.card-footer').attr('data-page', page);
            $('.' + row_object + '.approved-alternatives').empty();
            $('.' + row_object + '.approved-alternatives').append(data);
        },
        complete: function complete() {
            $('#load-approved-alternatives').unwrap();
        }
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
    var category_id = $(element).attr('id').replace("is_service","category_id");
    $('#'+tax_code_id).val(null).trigger("change").attr('data-source', Routes.autocomplete_overseers_tax_codes_path({"is_service": $(element).val()})).select2('destroy');
    $('#'+category_id).val(null).trigger("change").attr('data-source', Routes.autocomplete_closure_tree_overseers_categories_path({"is_service": $(element).val()})).select2('destroy');
    select2s();
};

export default manageFailedSkus