class Services::Overseers::SalesOrders::BuildFromSalesQuote < Services::Shared::BaseService
  def initialize(sales_quote, overseer)
    @sales_quote = sales_quote
    @overseer = overseer
  end

  def call
    @sales_order = sales_quote.sales_orders.build(overseer: overseer)

    sales_quote.rows.each do |row|
      sales_order.rows.build(sales_quote_row: row)
    end

    sales_order
  end

  attr_reader :sales_quote, :overseer, :sales_order
end
