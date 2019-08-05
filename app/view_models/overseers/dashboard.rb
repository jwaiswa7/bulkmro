class Overseers::Dashboard
  def initialize(current_overseer)
    @overseer = current_overseer
  end

  def inquiries
    inquiries_in_range = Inquiry.with_includes.where(inside_sales_owner_id: overseer.id).where('updated_at > ? OR quotation_followup_date > ?', Date.new(2018, 04, 01), Date.new(2018, 04, 01)).order(updated_at: :desc)
    inquiries_in_range.map{ |inquiry| inquiry if (inquiry.quotation_followup_date.present? && inquiry.quotation_followup_date == Date.today) || inquiry.updated_at.to_date + 2.day == Date.today }.compact
  end

  def sales_orders
    SalesOrder.with_includes.joins(:inquiry).where('inquiries.inside_sales_owner_id = ?', overseer.id).where('sales_orders.updated_at > ?', Date.new(2018, 04, 01)).latest
  end

  def recent_inquiries
    inquiries.first(15)
  end

  def inquiry_followup_count
    inquiries.count
  end

  def recent_sales_orders
    sales_orders.first(15)
  end

  attr_accessor :overseer
end
