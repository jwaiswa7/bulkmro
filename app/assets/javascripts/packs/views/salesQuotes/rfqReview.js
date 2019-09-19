// Imports

const rfqReview = () => {
    $('.generate_sales_quote').on('click',function(){
        let inquiry_product_supplier_ids = [];
        let inquiry_id = $('input[name="sales_quote[inquiry_id]"]').val();
        $.each($("input.supplier_id:checked"), function () {
            let $this = $(this);
            inquiry_product_supplier_ids.push($this.val())
        });
        let data = {inquiry_id: inquiry_id, inquiry_product_supplier_ids: inquiry_product_supplier_ids};
        window.open(Routes.new_overseers_inquiry_sales_quote_path(data), '_self');
    });
};

export default rfqReview