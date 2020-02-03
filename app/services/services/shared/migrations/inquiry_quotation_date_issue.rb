class Services::Shared::Migrations::InquiryQuotationDateIssue < Services::Shared::Migrations::Migrations
  def call
    inq = Inquiry.where('quotation_date < Date(created_at)')
    if inq.present?
      inq.each_with_index do |val, index|
      sales_quotes = val.sales_quotes
      if sales_quotes.present?
        val.quotation_date = sales_quotes.last.created_at.to_date
      else
        val.quotation_date = ''
      end
      val.save(validate: false)
    end
    end
  end
end
