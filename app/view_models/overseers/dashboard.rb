class Overseers::Dashboard
  def initialize(current_overseer)
    @overseer = current_overseer
  end

  def inquiries
    Inquiry.with_includes.where(:inside_sales_owner => overseer).where('updated_at > ?', Date.new(2018, 04, 01)).latest
  end

  def sales_quotes
    SalesQuote.with_includes.joins(:inquiry).where('inquiries.inside_sales_owner' => overseer).where("sales_quotes.updated_at > ?",Date.new(2018, 04, 01)).latest
  end

  def sales_orders
    SalesOrder.with_includes.joins(:inquiry).where('inquiries.inside_sales_owner' => overseer).where("sales_orders.updated_at > ?",Date.new(2018, 04, 01)).latest
  end

  def recent_inquiries
    inquiries.first(10)
  end

  def recent_sales_quotes
    sales_quotes.first(10)
  end

  def recent_sales_orders
    sales_orders.first(10)
  end

  attr_reader :overseer
end