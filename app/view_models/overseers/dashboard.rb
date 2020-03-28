class Overseers::Dashboard
  def initialize(current_overseer)
    @overseer = current_overseer
  end

  def inquiries
    Inquiry.with_includes.where(inside_sales_owner_id: overseer.id).where('updated_at > ? OR quotation_followup_date > ?', Date.new(2018, 04, 01), Date.new(2018, 04, 01)).where.not(status: ['Order Won', 'Order Lost', 'Regret', 'Regret Request']).order(updated_at: :desc).compact
  end

  def invoice_requests
    InvoiceRequest.where('updated_at > ?', Date.new(2019, 01, 01)).where.not(status: ['Completed AR Invoice Request', 'Cancelled AR Invoice', 'Cancelled', 'AP Invoice Request Rejected','GRPO Request Rejected','Inward Completed','Cancelled AP Invoice','Cancelled GRPO']).order(updated_at: :desc).compact
  end

  def inquiries_with_so_approval_pending
    Inquiry.where('created_at > ?', Date.new(2019, 01, 01)).where(status: 'SO Draft: Pending Accounts Approval').order(updated_at: :desc).compact
  end

  def inquiries_with_followup
    inquiries_in_range = Inquiry.with_includes.where(inside_sales_owner_id: overseer.id).where('updated_at > ? OR quotation_followup_date > ?', Date.new(2018, 04, 01), Date.new(2018, 04, 01)).where.not(status: ['Order Won', 'Order Lost', 'Regret', 'Regret Request']).order(updated_at: :desc)
    inquiries_in_range.map {
        |inquiry| inquiry if inquiry_needs_followup?(inquiry)
    }.compact
  end

  def inq_for_account_dash
    inq_from_invoice_request = []
    invoice_requests.each { |inv_req| inq_from_invoice_request.push inv_req.inquiry }
    inq_from_invoice_request.concat inquiries_with_so_approval_pending
  end

  def inq_for_dash
    if self.overseer.inside_sales_executive?
      Inquiry.with_includes.where(inside_sales_owner_id: overseer.id).where('updated_at > ? OR quotation_followup_date > ?', Date.new(2018, 04, 01), Date.new(2018, 04, 01)).where.not(status: ['Order Won', 'Order Lost', 'Regret', 'Rejected by Accounts']).order(updated_at: :desc)
    elsif self.overseer.accounts?
      inq_for_account_dash
    end
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
    if self.overseer.inside_sales_executive?
      recent_inquiry_ids = recent_inquiries.pluck(:id)
      InquiryComment.where(inquiry_id: recent_inquiry_ids).order(created_at: :desc).limit(10).group_by { |c| c.created_at.to_date }
    elsif self.overseer.accounts?
      invoice_request_ids = invoice_requests.pluck(:id)
      InvoiceRequestComment.where(invoice_request_id: invoice_request_ids).order(created_at: :desc).limit(8).group_by { |c| c.created_at.to_date }
    end

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
      value_parameter = document_calculated_total(recent_inquiries,status)
    elsif self.overseer.accounts?
      inv_req_status_array = invoice_requests.pluck(:status)
      inq_status_array = inq_for_dash.pluck(:status)
      count_parameter = inq_status_array.concat inv_req_status_array
      if inquiry_statuses.include? status
        value_parameter = document_calculated_total(inq_for_dash,status)
      else
        value_parameter = document_calculated_total(invoice_requests,status)
      end
    end
    {
        count: count_parameter.count(status),
        value: value_parameter
    }
  end

  def document_calculated_total(doc,status)
    if inquiry_statuses.include? status
      doc.map {  |inquiry| inquiry.calculated_total if inquiry.status == status }.compact.sum
    else
      doc.map {  |inv_req| inv_req.inquiry.calculated_total if inv_req.status == status }.compact.sum
    end
  end

  def inquiry_statuses
    ['Lead by O/S',
     'New Inquiry',
     'Acknowledgement Mail',
     'Cross Reference',
     'RFQ Sent',
     'PQ Received',
     'Preparing Quotation',
     'Quotation Sent',
     'Follow Up on Quotation',
     'Expected Order',
     'SO Not Created-Customer PO Awaited',
     'SO Not Created-Pending Customer PO Revision',
     'Draft SO for Approval by Sales Manager',
     'SO Draft: Pending Accounts Approval',
     'Order Won',
     'SO Rejected by Sales Manager',
     'Rejected by Accounts',
     'Hold by Accounts',
     'Order Lost',
     'Regret',
     'Regret Request']
  end

  def invoice_request_statuses
    ['GRPO Pending',
     'Pending AP Invoice',
     'Pending AR Invoice',
     'In stock',
     'Completed AR Invoice Request',
     'Cancelled AR Invoice',
     'Cancelled',
     'AP Invoice Request Rejected',
     'GRPO Request Rejected',
     'Inward Completed',
     'Cancelled AP Invoice',
     'Cancelled GRPO']
  end

  def recent_sales_orders
    sales_orders
  end

  attr_accessor :overseer
end
