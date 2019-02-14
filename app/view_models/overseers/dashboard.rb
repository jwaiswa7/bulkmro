

class Overseers::Dashboard
  def initialize(current_overseer)
    @overseer = current_overseer
  end

  def inquiries
    Inquiry.with_includes.where(inside_sales_owner_id: overseer.id).where('updated_at > ?', Date.new(2018, 04, 01)).latest
  end

  def sales_orders
    SalesOrder.with_includes.joins(:inquiry).where('inquiries.inside_sales_owner_id = ?', overseer.id).where('sales_orders.updated_at > ?', Date.new(2018, 04, 01)).latest
  end

  def recent_inquiries
    inquiries.first(15)
  end

  def recent_sales_orders
    sales_orders.first(15)
  end

  attr_accessor :overseer
end
