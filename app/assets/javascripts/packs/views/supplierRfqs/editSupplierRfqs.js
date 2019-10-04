// Imports

const editSupplierRfqs = () => {

    $('#select_all_isps').change(function () {
        $('input[name="inquiry_product_supplier_ids[]"]').each(function () {
            $(this).prop('checked', $('#select_all_isps').prop("checked")).trigger('change');
        });
    });

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

    rfqReview();
    updateAllInquiryProductSuppliers();

};

let rfqReview = () => {
    $('.rfq-review').click(function () {
        let inquiry_product_supplier_ids = [];
        let inquiry_id = $('input[name="supplier_rfq[inquiry_id]"]').val();
        $.each($("input[name='inquiry_product_supplier_ids[]']:checked"), function () {
            let $this = $(this);
            inquiry_product_supplier_ids.push($this.attr('id').split('inquiry_product_supplier_id_')[1]);
        });
        let data = {inquiry_id: inquiry_id, inquiry_product_supplier_ids: inquiry_product_supplier_ids};
        window.open(Routes.rfq_review_overseers_inquiry_sales_quotes_path(data), '_self');
    });
};
let updateAllInquiryProductSuppliers = () => {
    $(".update-all, .update-and-send-link-all").click(function () {
        let $this = $(this);
        let form_type = $this.val();
        $.each($("input[name='inquiry_product_supplier_ids[]']:checked"), function () {
            let $this1 = $(this);
            let form = $this1.closest('form');
            let input = $("<input>")
                .attr("type", "hidden")
                .attr("name", "button").val(form_type);
            form.append(input);
            form.submit();
        });
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