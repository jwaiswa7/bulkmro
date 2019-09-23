const editSupplierRfqs = () => {
    $(".rfq_edit :input").on('input', function(){
        let active_element_number = document.activeElement.id.match(/\d+/)[0]
        let final_unit_price = $("#supplier_rfq_inquiry_product_suppliers_attributes_" + active_element_number + "_final_unit_price").val();
        let quantity = $("#supplier_rfq_inquiry_product_suppliers_attributes_" + active_element_number + "_quantity").val();
        calculate_total_price(final_unit_price, quantity, active_element_number);
    });
};

let calculate_total_price = (final_unit_price, quantity, active_element_number) => {
    if (final_unit_price != null && quantity != null) {
        $("#supplier_rfq_inquiry_product_suppliers_attributes_" + active_element_number + "_total_price").val(parseFloat(final_unit_price) * parseFloat(quantity))
    }else{
        $("#supplier_rfq_inquiry_product_suppliers_attributes_" + active_element_number + "_total_price").val(0)
    }
};

export default editSupplierRfqs