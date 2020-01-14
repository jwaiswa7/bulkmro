const edit = () => {
    let gst = $('#inquiry_product_supplier_gst').val();
    let basic_unit_price = $('#inquiry_product_supplier_unit_cost_price').val();
    let final_unit_price = $('#inquiry_product_supplier_final_unit_price').val();
    let quantity = $('#inquiry_product_supplier_quantity').val();
    let freight = $('#inquiry_product_supplier_unit_freight').val();

    calculate_gst(gst, basic_unit_price);
    calculate_unit_freight(freight, final_unit_price);
    calculate_total_price(final_unit_price, quantity);

    $("#rfq_edit :input").on('input', function(){
        calculate_gst($('#inquiry_product_supplier_gst').val(), $('#inquiry_product_supplier_unit_cost_price').val());
        calculate_unit_freight($('#inquiry_product_supplier_unit_freight').val(), $('#inquiry_product_supplier_final_unit_price').val());
        calculate_total_price($('#inquiry_product_supplier_final_unit_price').val(), $('#inquiry_product_supplier_quantity').val());
        if (!($('#inquiry_product_supplier_unit_cost_price').val()) || $('#inquiry_product_supplier_unit_cost_price').val() == "0") {
            $('#inquiry_product_supplier_final_unit_price').val('');
            $('#inquiry_product_supplier_gst').val('');
            $('#inquiry_product_supplier_unit_freight').val('');
            $('#inquiry_product_supplier_total_price').val('');
        }
    });
};

let calculate_total_price = (final_unit_price, quantity) => {
    if (!(!final_unit_price && !quantity)) {
        $('#inquiry_product_supplier_total_price').val(parseFloat(final_unit_price) * parseFloat(quantity));
    }else{
        $('#inquiry_product_supplier_total_price').val('');
    }
};

let calculate_gst = (gst, basic_unit_price) => {
    if ((gst && gst != 0) && basic_unit_price) {
        let gst_value = parseFloat(basic_unit_price) * parseFloat(gst) / 100;
        $('#inquiry_product_supplier_final_unit_price').val(parseFloat(basic_unit_price) + parseFloat(gst_value));
    }else if(basic_unit_price) {
        $('#inquiry_product_supplier_final_unit_price').val(parseFloat(basic_unit_price));
    }
};

let calculate_unit_freight = (freight, final_unit_price) => {
    if (freight) {
        $('#inquiry_product_supplier_final_unit_price').val(parseFloat(freight) + parseFloat(final_unit_price));
    }
};

export default edit