const edit = () => {
    let gst = $('#inquiry_product_supplier_gst').val();
    let basic_unit_price = $('#inquiry_product_supplier_unit_cost_price').val();
    let final_unit_price = $('#inquiry_product_supplier_final_unit_price').val();
    let quantity = $('#inquiry_product_supplier_quantity').val();

    calculate_gst(gst, basic_unit_price);
    calculate_total_price(final_unit_price, quantity);

    $("#rfq_edit :input").on('input', function(){
        calculate_gst($('#inquiry_product_supplier_gst').val(), $('#inquiry_product_supplier_unit_cost_price').val());
        calculate_total_price($('#inquiry_product_supplier_final_unit_price').val(), $('#inquiry_product_supplier_quantity').val());
    });
};

let calculate_total_price = (final_unit_price, quantity) => {
    if (!(!final_unit_price && !quantity)) {
        $('#inquiry_product_supplier_total_price').val(parseFloat(final_unit_price) * parseFloat(quantity));
    }else{
        $('#inquiry_product_supplier_total_price').val(0);
    }
};

let calculate_gst = (gst, basic_unit_price) => {
    if ((gst && gst != 0) && basic_unit_price) {
        let gst_value = parseFloat(basic_unit_price) * parseFloat(gst) / 100
        $('#inquiry_product_supplier_final_unit_price').val(parseFloat(basic_unit_price) + parseFloat(gst_value));
    }else if(basic_unit_price) {
        $('#inquiry_product_supplier_final_unit_price').val(parseFloat(basic_unit_price));
    }
};

export default edit