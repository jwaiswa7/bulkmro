import select2s from "../../components/select2s";

var categoryStatus = 0;

const newAction = () => {
    let is_service = $('input[name*=is_service]')[1].id;
    //onIsServiceChecked($("#"+is_service).is("checked"));

    if($('select[name*=category_id]').length != 0){
        categoryStatus = 1;
        console.log("In If Condition");
        onIsServiceChecked($("#"+is_service).is("checked"));
    }
    else{
        categoryStatus = 0;
        onIsServiceChecked($("#"+is_service).is("checked"));
    }

    $('form').on('change', '[name*=is_service]', function (event) {
        $("#"+$('select[name*=tax_code_id]')[0].id).val(null).trigger("change");
        $("#"+$('select[name*=category_id]')[0].id).val(null).trigger("change");
        onIsServiceChecked(event.target.checked);
        categoryStatus=1;
    })
};

let onIsServiceChecked = (is_service_status) => {
    $("#"+$('select[name*=tax_code_id]')[0].id).attr('data-source', Routes.autocomplete_overseers_tax_codes_path({"is_service": is_service_status})).select2('destroy');
    if(categoryStatus==1){
        $("#"+$('select[name*=category_id]')[0].id).attr('data-source', Routes.autocomplete_closure_tree_overseers_categories_path({"is_service": is_service_status})).select2('destroy');
    }
    select2s();
};

export default newAction