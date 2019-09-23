const edit = () => {
    calculate_total_price($('#inquiry_product_supplier_final_unit_price').val(), $('#inquiry_product_supplier_quantity').val());
    $("#rfq_edit :input").on('input', function(){
        calculate_total_price($('#inquiry_product_supplier_final_unit_price').val(), $('#inquiry_product_supplier_quantity').val());
    });
};

let calculate_total_price = (final_unit_price, quantity) => {
    if (final_unit_price != null && quantity != null) {
        $('#inquiry_product_supplier_total_price').val(parseFloat(final_unit_price) * parseFloat(quantity))
    }else{
        $('#inquiry_product_supplier_total_price').val(0)
    }
};

export default edit