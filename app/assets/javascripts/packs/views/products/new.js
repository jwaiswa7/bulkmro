import select2s from "../../components/select2s";

const newAction = () => {
    $(document).ready(function(){
        $("#product_tax_code_id").val(null).trigger("change");
        product_Tax_Identification();
    });
    if($("#product_is_service").is(":checked")){
        product_Tax_Identification();
    }
    $("#product_is_service").click(function(event){
        product_Tax_Identification();
        $("#product_tax_code_id").val(null).trigger("change");
    });

    function product_Tax_Identification(){
        $('#product_tax_code_id').attr('data-source', Routes.autocomplete_overseers_tax_codes_path({"data": $("#product_is_service").is(":checked")})).select2('destroy');
        select2s();
    }
};

export default newAction