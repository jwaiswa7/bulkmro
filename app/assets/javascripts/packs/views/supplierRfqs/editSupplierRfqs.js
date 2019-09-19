// Imports

const editSupplierRfqs = () => {
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

export default editSupplierRfqs