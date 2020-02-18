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

    $('.reset_sales_quote').on('click',function(){
        let inquiry_product_supplier_ids = [];
        let inquiry_id = $('input[name="sales_quote[inquiry_id]"]').val();
        let sales_quote_id = $('input[name="sales_quote[parent_id]"]').val();
        $.each($("input.supplier_id:checked"), function () {
            let $this = $(this);
            inquiry_product_supplier_ids.push($this.val())
        });
        let data = {inquiry_product_supplier_ids: inquiry_product_supplier_ids};
        console.log(inquiry_product_supplier_ids);
        window.open(Routes.new_revision_overseers_inquiry_sales_quote_path(inquiry_id, sales_quote_id, data), '_self');
    });
};

export default rfqReview