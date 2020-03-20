class Overseers::Dashboard
  def initialize(current_overseer)
    @overseer = current_overseer
  end

  def inquiries
    Inquiry.with_includes.where(inside_sales_owner_id: overseer.id).where('updated_at > ? OR quotation_followup_date > ?', Date.new(2018, 04, 01), Date.new(2018, 04, 01)).where.not(status: ['Order Won', 'Order Lost', 'Regret', 'Regret Request']).order(updated_at: :desc).compact
  end

  def invoice_requests
    InvoiceRequest.where('updated_at > ?', Date.new(2018, 04, 01)).where.not(status: ['Completed AR Invoice Request', 'Cancelled AR Invoice', 'Cancelled', 'AP Invoice Request Rejected','GRPO Request Rejected','Inward Completed','Cancelled AP Invoice','Cancelled GRPO']).order(updated_at: :desc).compact
  end

  def inquiries_with_so_approval_pending
    Inquiry.where('updated_at > ?', Date.new(2018, 04, 01)).where(status: 'SO Draft: Pending Accounts Approval').order(updated_at: :desc).compact
  end

  def inquiries_with_followup
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
        inquiry.quotation_followup_date > inquiry.updated_at.to_date && inquiry.quotation_followup_date <= Date.today - 2.day)) )
  end

  def inquiry_followup_count
    inquiries_with_followup.count
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
    if self.overseer.inside_sales_executive?
      ['New Inquiry', 'Preparing Quotation', 'Quotation Sent', 'Follow Up on Quotation', 'Expected Order']
    elsif self.overseer.accounts?
      ['GRPO Pending', 'Pending AP Invoice', 'Pending AR Invoice', 'SO Draft: Pending Accounts Approval']
    end
  end

  def get_status_metrics(status)
    if self.overseer.inside_sales_executive?
      count_parameter = recent_inquiries.pluck(:status)
      value_parameter = inquiry_calculated_total(nil,status)
    elsif self.overseer.accounts?
      count_parameter = invoice_requests.pluck(:status)
      count_parameter = count_parameter.concat (inquiries_with_so_approval_pending.pluck(:status))
      value_parameter = inquiry_calculated_total(nil,invoice_requests)
    end
    {
        count: count_parameter.count(status),
        value: value_parameter
    }
  end

  def inquiry_calculated_total(documents,status)
    if documents
      documents.map { |doc| doc.inquiry.calculated_total if doc.status == status }.compact.sum
    else
      recent_inquiries.map { |inquiry| inquiry.calculated_total if inquiry.status == status }.compact.sum
    end
  end

  def recent_sales_orders
    sales_orders
  end

  attr_accessor :overseer
end
