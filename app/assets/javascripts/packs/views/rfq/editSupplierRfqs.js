const editSupplierRfqs = () => {
    $(".rfq_edit :input").on('input', function(){
        let active_element_number = document.activeElement.id.match(/\d+/)[0];
        let basic_unit_price = $("#supplier_rfq_inquiry_product_suppliers_attributes_" + active_element_number + "_unit_cost_price").val();
        let gst = $("#supplier_rfq_inquiry_product_suppliers_attributes_" + active_element_number + "_gst").val();
        let unit_freight = $("#supplier_rfq_inquiry_product_suppliers_attributes_" + active_element_number + "_unit_freight").val();
        let final_unit_price = $("#supplier_rfq_inquiry_product_suppliers_attributes_" + active_element_number + "_final_unit_price").val();
        let quantity = $("#supplier_rfq_inquiry_product_suppliers_attributes_" + active_element_number + "_quantity").val();
        calculate_gst(gst, basic_unit_price, active_element_number);
        calculate_freight(unit_freight, final_unit_price, active_element_number);
        calculate_total_price($("#supplier_rfq_inquiry_product_suppliers_attributes_" + active_element_number + "_final_unit_price").val(), quantity, active_element_number);
        if (!(basic_unit_price) || basic_unit_price == "0") {
            $("#supplier_rfq_inquiry_product_suppliers_attributes_" + active_element_number + "_final_unit_price").val('');
            $("#supplier_rfq_inquiry_product_suppliers_attributes_" + active_element_number + "_gst").val('');
            $("#supplier_rfq_inquiry_product_suppliers_attributes_" + active_element_number + "_unit_freight").val('');
            $("#supplier_rfq_inquiry_product_suppliers_attributes_" + active_element_number + "_total_price").val('');
        }
    });
};

let calculate_gst = (gst, basic_unit_price, active_element_number) => {
    if ((gst && gst != 0) && basic_unit_price) {
        let gst_value = parseFloat(basic_unit_price) * parseFloat(gst) / 100;
        $("#supplier_rfq_inquiry_product_suppliers_attributes_" + active_element_number + "_final_unit_price").val(parseFloat(basic_unit_price) + parseFloat(gst_value));
    }else if(basic_unit_price) {
        $("#supplier_rfq_inquiry_product_suppliers_attributes_" + active_element_number + "_final_unit_price").val(parseFloat(basic_unit_price));
    }
};

let calculate_freight = (unit_freight, final_unit_price, active_element_number) => {
    if (unit_freight) {
        $("#supplier_rfq_inquiry_product_suppliers_attributes_" + active_element_number + "_final_unit_price").val(parseFloat(unit_freight) + parseFloat(final_unit_price));
    }
};

let calculate_total_price = (final_unit_price, quantity, active_element_number) => {
    if (final_unit_price != null && quantity != null) {
        $("#supplier_rfq_inquiry_product_suppliers_attributes_" + active_element_number + "_total_price").val(parseFloat(final_unit_price) * parseFloat(quantity));
    }else{
        $("#supplier_rfq_inquiry_product_suppliers_attributes_" + active_element_number + "_total_price").val('');
    }
};

export default editSupplierRfqs