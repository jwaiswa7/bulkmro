class Services::Shared::Snippets < Services::Shared::BaseService

  def delete_all_inquiries
    SalesOrderRow.delete_all
    SalesOrderApproval.all.delete_all
    SalesOrderConfirmation.delete_all
    SalesOrderRejection.delete_all
    SalesOrderApproval.delete_all
    SalesOrder.delete_all
    SalesQuoteRow.delete_all
    SalesQuote.delete_all
    InquiryProductSupplier.delete_all
    InquiryImportRow.delete_all
    InquiryImport.delete_all
    InquiryProduct.delete_all
    ActivityOverseer.delete_all
    Activity.delete_all
    InquiryComment.delete_all
    Inquiry.delete_all
  end

  def delete_inquiry_products
    SalesQuoteRow.delete_all
    SalesQuote.delete_all
    InquiryProductSupplier.delete_all
    InquiryProduct.delete_all

  end

end