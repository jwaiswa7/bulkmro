class Services::Overseers::SalesQuotes::SalesQuoteResetByManager < Services::Shared::BaseService
  def initialize(sales_quote, params)
    @sales_quote = sales_quote
    @params = params
  end
  def call
    if sales_quote.present? && params['inquiry']['comments_attributes']['0']['message'].present?
      @inquiry_comment = InquiryComment.new
      @inquiry_comment.inquiry_id =  sales_quote.inquiry.id
      @inquiry_comment.message = "Sales Quote Reset for #{sales_quote.id}:  Reason #{params['inquiry']['comments_attributes']['0']['message']}"
      @inquiry_comment.created_by_id = params[:overseer].id
      @inquiry_comment.updated_by_id = params[:overseer].id
      @inquiry_comment.save!

      @inquiry = sales_quote.inquiry
      @inquiry.update_attributes(quotation_uid: '')
      @inquiry.final_sales_quote.update_attributes(remote_uid: '')
    end
  end

  attr_accessor :sales_quote, :params
end