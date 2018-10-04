class Services::Shared::Snippets < Services::Shared::BaseService

  def delete_all_inquiries
    SalesOrderRow.delete_all
    SalesOrder.delete_all
    SalesQuoteRow.delete_all
    SalesQuote.delete_all
    InquiryProductSupplier.delete_all
    InquiryProduct.delete_all
    ActivityOverseer.delete_all
    Activity.delete_all
    InquiryComment.delete_all
    Inquiry.delete_all
  end

end