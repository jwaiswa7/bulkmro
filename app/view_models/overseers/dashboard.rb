class Overseers::Dashboard
  def initialize(current_overseer)
    @overseer = current_overseer
  end

  def inquiries
    Inquiry.with_includes.where(:inside_sales_owner => overseer).where('updated_at > ?', Date.new(2018, 04, 01)).latest
  end

  def sales_quotes
    SalesQuote.with_includes.joins(:inquiry).where('inquiries.inside_sales_owner' => overseer).where("sales_quotes.updated_at > ?",Date.new(2018, 04, 01)).latest
    # .where.not(:sent_at => nil).order("inquiries.inquiry_number DESC").distinct(:inquiry_id).uniq {|p| p.inquiry_id}
  end

  def sales_orders
    SalesOrder.with_includes.joins(:inquiry).where('inquiries.inside_sales_owner' => overseer).where("sales_orders.created_at > ?",Date.new(2018, 04, 01)).latest
  end

  def recent_inquiries
    inquiries.first(5)
  end

  def recent_sales_quotes
    sales_quotes.first(5)
  end

  def recent_sales_orders
    sales_orders.first(5)
  end

  attr_reader :overseer
end