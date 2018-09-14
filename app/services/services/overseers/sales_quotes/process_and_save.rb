class Services::Overseers::SalesQuotes::ProcessAndSave < Services::Shared::BaseService
  def initialize(sales_quote)
    @sales_quote = sales_quote
  end

  def call
    sales_quote.rows.each do |row|
      row.converted_unit_selling_price = row.calculated_converted_unit_selling_price
    end

    sales_quote.save
  end

  attr_reader :sales_quote
end