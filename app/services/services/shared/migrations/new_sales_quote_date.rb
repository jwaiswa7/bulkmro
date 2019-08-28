class Services::Shared::Migrations::NewSalesQuoteDate < Services::Shared::Migrations::Migrations
  def change_quote_date_in_inquiry
    service = Services::Shared::Spreadsheets::CsvImporter.new('changes_sales_quotes.csv', 'seed_files_3')
    service.loop do |x|
      inquiry_number = x.get_column('inquiry_number')
      if inquiry_number.present?
        inquiry = Inquiry.find_by_inquiry_number(inquiry_number)
        if inquiry.present?
          sales_quotes = inquiry.sales_quotes
          if sales_quotes.present?
            sales_quote = sales_quotes.first
            inquiry.update_attributes(quotation_date: sales_quote.created_at)
          else
            inquiry.update_attributes(quotation_date: "")
          end
        end
      end
    end
  end
end