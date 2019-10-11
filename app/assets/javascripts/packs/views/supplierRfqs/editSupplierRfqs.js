// Imports

const editSupplierRfqs = () => {

    $('#select_all_isps').change(function () {
        $('input[name="inquiry_product_supplier_ids[]"]').each(function () {
            $(this).prop('checked', $('#select_all_isps').prop("checked")).trigger('change');
        });
    });

    $(".rfq_edit :input").on('change', function () {
        let data_id= $(this).data('id');
        let active_element_number = typeof data_id === 'undefined' ? '' : data_id.split('_').pop();
        let basic_unit_price = $('input[data-id="unit_cost_price_' + active_element_number + '"]').val() || 0;
        let gst = $('select[data-id="gst_' + active_element_number + '"]').val();
        let unit_freight = $('input[data-id="unit_freight_' + active_element_number + '"]').val() || 0;

        calculate_final_unit_price(gst, basic_unit_price, unit_freight, active_element_number);

        if (!(basic_unit_price) || basic_unit_price == "0") {
            $('input[data-id="final_unit_price_' + active_element_number + '"]').val('');
            $('input[data-id="gst_' + active_element_number + '"]').val('');
            $('input[data-id="unit_freight_' + active_element_number + '"]').val('');
            $('input[data-id="total_price_' + active_element_number + '"]').val('');
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

let calculate_final_unit_price = (gst, basic_unit_price, unit_freight, active_element_number) => {
    let final_unit_price_input = $("form").find("[data-id='final_unit_price_" + active_element_number + "']");
    let quantity = $('input[data-id="quantity_' + active_element_number + '"]').val();
    let final_unit_price;
    if ((gst && gst != 0) && basic_unit_price) {
        let unit_price_with_gst = (parseFloat(basic_unit_price) * parseFloat(gst) / 100) || 0;
        let unit_price_with_freight = parseFloat(unit_freight)  || 0;
        final_unit_price = parseFloat(basic_unit_price) + unit_price_with_gst + unit_price_with_freight;
        final_unit_price_input.val(parseFloat(final_unit_price).toFixed(2));
    } else if (basic_unit_price) {
        let unit_price_with_gst = 0;
        let unit_price_with_freight = parseFloat(unit_freight)  || 0;
        final_unit_price = parseFloat(basic_unit_price) + unit_price_with_gst + unit_price_with_freight;
        final_unit_price_input.val(parseFloat(final_unit_price).toFixed(2));
    }
    calculate_total_price(final_unit_price, quantity, active_element_number)
};

let calculate_total_price = (final_unit_price, quantity, active_element_number) => {
    let total_unit_price_input = $('input[data-id="total_price_' + active_element_number + '"]');
    if (final_unit_price != null && quantity != null) {
        let total = parseFloat(final_unit_price) * parseFloat(quantity);
        total_unit_price_input.val(total.toFixed(2));
    } else {
        total_unit_price_input.val('');
    }
};

export default editSupplierRfqs