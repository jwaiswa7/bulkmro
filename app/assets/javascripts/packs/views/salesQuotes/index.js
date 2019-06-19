import callAjaxFunction from "../common/callAjaxFunction";

const index = () => {
    $('.manager-sales-quote-reset').on('click',function(){

        var quoteId = $(this).data('salesQuoteId')
        var inquiryId = $(this).data('inquiryId')
        var title = ""
        if(quoteId != null && inquiryId!= null){
            var json = {
                url: '/overseers/inquiries/'+inquiryId+'/sales_quotes/'+quoteId+'/reset_quote_form',
                modalId: '#reset-sales-quote-by-manager',
                className: '.sales-quote-cancel-manager-form',
                buttonClassName: '.manager-sales-quote-reset',
                this: $(this),
                title: title
            }
            callAjaxFunction(json)
        }

    })
}

export default index