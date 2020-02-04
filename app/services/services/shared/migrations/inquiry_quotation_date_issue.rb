class Services::Shared::Migrations::InquiryQuotationDateIssue < Services::Shared::Migrations::Migrations
  def call
    inq = Inquiry.where('quotation_date < Date(created_at)')
    if inq.present?
      inq.each do |val|
      sales_quote = val.final_sales_quote
      if sales_quote.present?
        val.quotation_date = sales_quote.created_at.to_date
      else
        val.quotation_date = ''
      end
      val.save(validate: false)
    end
    end
  end
end
