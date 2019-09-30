// Imports

const editSupplierRfqs = () => {

    $('#select_all_isps').change(function () {
        $('input[name="inquiry_product_supplier_ids[]"]').each(function () {
            $(this).prop('checked', $('#select_all_isps').prop("checked")).trigger('change');
        });
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

export default editSupplierRfqs