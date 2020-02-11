class Overseers::Dashboard
  def initialize(current_overseer)
    @overseer = current_overseer
  end

  def inquiries
    inquiries_in_range = Inquiry.with_includes.where(inside_sales_owner_id: overseer.id).where('updated_at > ? OR quotation_followup_date > ?', Date.new(2018, 04, 01), Date.new(2018, 04, 01)).where.not(status: ['Order Won', 'Order Lost', 'Regret', 'Regret Request']).order(updated_at: :desc)
    inquiries_in_range.map {
        |inquiry| inquiry if inquiry_needs_followup?(inquiry)
    }.compact
  end

  def inq_for_sales_dash
    Inquiry.with_includes.where(inside_sales_owner_id: overseer.id).where('updated_at > ? OR quotation_followup_date > ?', Date.new(2018, 04, 01), Date.new(2018, 04, 01)).where.not(status: ['Order Won', 'Order Lost', 'Regret', 'Rejected by Accounts']).order(updated_at: :desc)
  end

  def inquiry_needs_followup?(inquiry)
    ((inquiry.quotation_followup_date.present? &&
        (inquiry.quotation_followup_date == Date.today ||
            inquiry.quotation_followup_date < inquiry.updated_at.to_date && inquiry.updated_at.to_date <= Date.today - 2.day ||
            inquiry.quotation_followup_date > inquiry.updated_at.to_date && inquiry.quotation_followup_date <= Date.today - 2.day)) ||
        (inquiry.updated_at.to_date <= Date.today - 2.day))
  end

  def inquiry_followup_count
    inquiries.count
  end

  def sales_orders
    SalesOrder.with_includes.joins(:inquiry).where('inquiries.inside_sales_owner_id = ?', overseer.id).where('sales_orders.updated_at > ?', Date.new(2018, 04, 01)).latest
  end

  def recent_inquiries
    inquiries
  end

  def notifications
    Notification.where(recipient: overseer).order(created_at: :desc).limit(10).group_by { |c| c.created_at.to_date }
  end

  def comments
    recent_inquiry_ids = recent_inquiries.pluck(:id)
    InquiryComment.where(inquiry_id: recent_inquiry_ids).order(created_at: :desc).limit(10).group_by { |c| c.created_at.to_date }
  end

  def main_statuses
    ['New Inquiry', 'Preparing Quotation', 'Quotation Sent', 'Follow Up on Quotation', 'Expected Order']
  end

  def get_status_metrics(status)
    {
        count: recent_inquiries.pluck(:status).count(status),
        value: recent_inquiries.map { |inquiry| inquiry.calculated_total if inquiry.status == status }.compact.sum
    }
  end

  def recent_sales_orders
    sales_orders
  end

  attr_accessor :overseer
end
