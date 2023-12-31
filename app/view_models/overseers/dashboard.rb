class Overseers::Dashboard
  def initialize(current_overseer, pagination = false, page = nil ,inq_status = nil)
    @overseer = current_overseer
    @page = page
    @pagination = pagination
    @inq_status = inq_status
    @per = 5
  end

  def inquiries
    Inquiry.with_includes.where(inside_sales_owner_id: overseer.id).where('updated_at > ? OR quotation_followup_date > ?', Date.new(2018, 04, 01), Date.new(2018, 04, 01)).where.not(status: ['Order Won', 'Order Lost', 'Regret', 'Regret Request']).order(updated_at: :desc).compact
  end

  def inquiries_with_pagination
    Kaminari.paginate_array(Inquiry.with_includes.where(inside_sales_owner_id: overseer.id).where('updated_at > ? OR quotation_followup_date > ?', Date.new(2018, 04, 01), Date.new(2018, 04, 01)).where.not(status: ['Order Won', 'Order Lost', 'Regret', 'Regret Request']).order(updated_at: :desc).compact).page(page).per(per)
  end

  def filtered_inquiries_with_pagination(status)
    Kaminari.paginate_array(Inquiry.with_includes.where(inside_sales_owner_id: overseer.id).where('updated_at > ? OR quotation_followup_date > ?', Date.new(2018, 04, 01), Date.new(2018, 04, 01)).where.not(status: ['Order Won', 'Order Lost', 'Regret', 'Regret Request']).order(updated_at: :desc).map { |inquiry| inquiry if inquiry.status == status }.compact).page(page).per(per)
  end

  def inquiries_for_manager
    Rails.cache.fetch([self, 'inquiries_for_manager'], expires_in: 1.hours) do
      Inquiry.with_includes.where('created_at > ? OR quotation_followup_date > ?', Date.new(2018, 04, 01), Date.new(2018, 04, 01)).where(status: ['New Inquiry', 'Acknowledgement Mail', 'Cross Reference', 'RFQ Sent', 'PQ Received', 'Preparing Quotation', 'Follow Up on Quotation', 'SO Not Created-Pending Customer PO Revision', 'SO Draft: Pending Accounts Approval', 'SO Not Created-Customer PO Awaited'], inside_sales_owner_id: overseer.self_and_descendant_ids).order(updated_at: :desc).compact
    end
  end

  def inquiries_to_calculate_potential_amount
    Rails.cache.fetch([self, 'inquiries_to_calculate_potential_amount'], expires_in: 1.hours) do
      Inquiry.with_includes.where('created_at > ? OR quotation_followup_date > ?', Date.new(2018, 04, 01), Date.new(2018, 04, 01)).where(status: ['New Inquiry', 'Acknowledgement Mail', 'Cross Reference', 'RFQ Sent', 'PQ Received', 'Preparing Quotation']).order(updated_at: :desc).compact
    end
  end

  def invoice_requests_grpo_pending
    InvoiceRequest.where('created_at > ?', Date.new(2019, 01, 01)).where(status: 'GRPO Pending').order(updated_at: :desc).compact
  end

  def invoice_requests_ap_invoice_pending
    InvoiceRequest.where('created_at > ?', Date.new(2019, 01, 01)).where(status: 'Pending AP Invoice').order(updated_at: :desc).compact
  end

  def ar_invoice_requests
    ArInvoiceRequest.where('created_at > ?', Date.new(2019, 01, 01)).where(status: 'AR Invoice requested').order(updated_at: :desc).compact
  end

  def so_with_so_approval_pending
    SalesOrder.where(status: 'Accounts Approval Pending').where('created_at > ?', Date.new(2019, 06, 01)).compact
  end

  def inquiries_with_so_approval_pending
    Inquiry.joins(:sales_orders).where(sales_orders: {status: 'Accounts Approval Pending'}).where('sales_orders.created_at > ?', Date.new(2019, 06, 01)).compact
  end

  def inquiries_with_followup
    inquiries_in_range = Inquiry.with_includes.where(inside_sales_owner_id: overseer.id).where('updated_at > ? OR quotation_followup_date > ?', Date.new(2018, 04, 01), Date.new(2018, 04, 01)).where.not(status: ['Order Won', 'Order Lost', 'Regret', 'Regret Request']).order(updated_at: :desc)
    inquiries_in_range.map {
        |inquiry| inquiry if inquiry_needs_followup?(inquiry)
    }.compact
  end

  def inq_for_account_dash
    account_task_hash = Settings.account_dashboard_task
    parsed_hash = ActiveSupport::JSON.decode(account_task_hash)
    account_person = self.overseer.email
    total_inq = []
    parsed_hash[account_person].each do |status|
      if status == 'GRPO Pending'
        total_inq += invoice_requests_grpo_pending.pluck(:inquiry_id)
      elsif status == 'AR Invoice requested'
        total_inq += ar_invoice_requests.pluck(:inquiry_id)
      elsif status == 'Pending AP Invoice'
        total_inq += invoice_requests_ap_invoice_pending.pluck(:inquiry_id)
      elsif status == 'SO: Pending Accounts Approval'
        total_inq += inquiries_with_so_approval_pending.pluck(:id)
      end
    end
    total_inq = Inquiry.where(id: total_inq)
    total_inq
  end
  def inq_for_sales_manager_dash
    inquiries_for_manager.group_by(&:inside_sales_owner_id)
  end

  def inq_for_sales_manager_dash_by_name
    inq_for_sales_manager_dash.map { |id, inquiries| [Overseer.find_by_id(id).name, inquiries] }.to_h
  end

  def inq_for_dash(executivelink = nil , inquiry_status = nil)
    status_name = inquiry_status.present? ?  inquiry_status : inq_status.present? ?  inq_status : nil
    if self.overseer.sales?
      if self.overseer.descendant_ids.present? && !executivelink
        inquiries_for_manager
      elsif status_name.present? && pagination
        filtered_inquiries_with_pagination(status_name)
      elsif pagination
        inquiries_with_pagination
      else
        recent_inquiries
      end
    elsif self.overseer.accounts_role_for_dashboard?
      inq_for_account_dash
    end
  end

  def inquiry_needs_followup?(inquiry)
    ((inquiry.quotation_followup_date.present? &&
        (inquiry.quotation_followup_date == Date.today ||
            inquiry.quotation_followup_date < inquiry.updated_at.to_date && inquiry.updated_at.to_date <= Date.today - 2.day ||
            inquiry.quotation_followup_date > inquiry.updated_at.to_date && inquiry.quotation_followup_date <= Date.today - 2.day)))
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

  def comments(executivelink = nil)
    if self.overseer.sales?
      if self.overseer.descendant_ids.present? && !executivelink
        inquiries_for_manager_ids = inquiries_for_manager.pluck(:id)
        InquiryComment.where(inquiry_id: inquiries_for_manager_ids).order(created_at: :desc).limit(10).group_by { |c| c.created_at.to_date }
      else
        recent_inquiry_ids = recent_inquiries.pluck(:id)
        InquiryComment.where(inquiry_id: recent_inquiry_ids).order(created_at: :desc).limit(10).group_by { |c| c.created_at.to_date }
      end
    elsif executivelink.nil? && self.overseer.accounts_role_for_dashboard?
      invoice_request_ids = invoice_requests_grpo_pending.pluck(:id) + invoice_requests_ap_invoice_pending.pluck(:id)
      InvoiceRequestComment.where(invoice_request_id: invoice_request_ids).order(created_at: :desc).limit(8).group_by { |c| c.created_at.to_date }
    end
  end

  def main_statuses(executivelink = nil)
    if self.overseer.sales?
      if self.overseer.descendant_ids.present? && !executivelink
        {
            'Acknowledgement Pending' => ['New Inquiry'],
            'Preparing Quotation' => ['New Inquiry', 'Acknowledgement Mail', 'Cross Reference', 'RFQ Sent', 'PQ Received', 'Preparing Quotation'],
            'Follow Up' => ['Follow Up on Quotation'],
            'Awaited Customer PO' => ['SO Not Created-Customer PO Awaited', 'SO Not Created-Pending Customer PO Revision'],
            'SO: Pending Accounts Approval' => ['SO Draft: Pending Accounts Approval']
        }
      else
        ['New Inquiry', 'Preparing Quotation', 'Quotation Sent', 'Follow Up on Quotation', 'Expected Order']
      end
    end
  end

  def main_statuses_accounts(account_exe = nil)
    account_summary_bucket = {
        'GRPO Pending' => ['GRPO Pending'],
        'Pending AP Invoice' => ['Pending AP Invoice'],
        'AR Invoice requested' => ['AR Invoice requested'],
        'SO: Pending Accounts Approval' => ['Accounts Approval Pending']
    }
    account_task_hash = Settings.account_dashboard_task
    parsed_hash = ActiveSupport::JSON.decode(account_task_hash)
    if account_exe.nil?
      account_person = self.overseer.email
    else
      account_person = account_exe
    end
    bucket_hash = Hash.new
    parsed_hash[account_person].each do |bucket_name|
      bucket_hash[bucket_name] = account_summary_bucket[bucket_name]
    end
    bucket_hash
  end

  def get_status_metrics(status)
    if self.overseer.sales?
      count_parameter = recent_inquiries.pluck(:status)
      value_parameter = inquiries_calculated_total(recent_inquiries, status)
    end
    {
        count: count_parameter.present? ? count_parameter.count(status) : 0,
        value: value_parameter.present? ? value_parameter : 0
    }
  end

  def get_status_metrics_for_accounts(status_arr)
    total_count = 0
    count_parameter = invoice_requests_grpo_pending.pluck(:status) + invoice_requests_ap_invoice_pending.pluck(:status) + so_with_so_approval_pending.pluck(:status) + ar_invoice_requests.pluck(:status)
    status_arr.each { |status| total_count = total_count + count_parameter.count(status) }
    # value_parameter = inquiries_calculated_total(inquiries_for_manager, status_arr)
    if sales_order_statuses.include? status_arr.first
      value_parameter = get_calculated_sales_order(so_with_so_approval_pending)
    elsif invoice_request_status.include? status_arr.first
      value_parameter = get_calculated_invoice_request(invoice_requests_grpo_pending + invoice_requests_ap_invoice_pending, status_arr.first)
    elsif inquiry_statuses.include? status_arr.first
      value_parameter = inquiries_calculated_total(inq_for_dash, status_arr.first)
    else
      value_parameter = get_calculated_ar_invoice_request(ar_invoice_requests)
    end
    {
        count: total_count,
        value: value_parameter.present? ? value_parameter : 0
    }
  end

  def main_statuses_accounts_with_metrics(account_exe = nil)
    statuses_bucket_hash = main_statuses_accounts(account_exe)
    bucket_with_metric_hash = {}
    statuses_bucket_hash.each do |box_name, status_names|
      metric_hash = {}
      metric_hash['count'] = get_status_metrics_for_accounts(status_names)[:'count']
      metric_hash['value'] = get_status_metrics_for_accounts(status_names)[:'value']
      bucket_with_metric_hash[box_name] = metric_hash
    end
    bucket_with_metric_hash
  end

  def get_status_metrics_for_sales_manager(status_arr)
    total_count = 0
    count_parameter = inquiries_for_manager.pluck(:status)
    status_arr.each { |status| total_count += count_parameter.count(status) }
    value_parameter = inquiries_calculated_total(inquiries_for_manager, status_arr)
    {
        count: total_count,
        value: value_parameter.present? ? value_parameter : 0
    }
  end

  def inquiries_potential_total(doc, status)
    doc.map {  |inquiry| inquiry.calculated_total if inquiry.status == status }.compact.sum
  end

  def inquiries_calculated_total(doc, status)
    total_value = 0
    if status.is_a?(Array)
      status_wo_sales_quote_arr = ['New Inquiry', 'Acknowledgement Mail', 'Cross Reference', 'RFQ Sent', 'PQ Received', 'Preparing Quotation']
      status.each do |each_status|
        if status_wo_sales_quote_arr.include? each_status
          total_value += doc.map {  |inquiry| inquiry.potential_value(each_status) if inquiry.status == each_status }.compact.sum
        else
          total_value += doc.map {  |inquiry| inquiry.calculated_total if inquiry.status == each_status }.compact.sum
        end
      end
    else
      total_value = doc.map {  |inquiry| inquiry.calculated_total if inquiry.status == status }.compact.sum
    end
    total_value
  end

  def get_calculated_sales_order(so_arr)
    total_price_arr = []
    so_arr.each do |so|
      total_price_arr.push so.converted_total_with_tax
    end
    total_price_arr.sum
  end

  def get_calculated_invoice_request(invoice_requests_arr, status)
    total_price_arr = []
    invoice_requests_arr.each do |invoice_req|
      if invoice_req.status == status
        service = Services::Overseers::InvoiceRequests::FormProductsList.new(invoice_req.inward_dispatches.ids, false)
        products_list = service.call

        products_list.each do |product|
          total_price_arr.push(product[:purchase_order_row].unit_selling_price.to_f * product[:total_quantity].to_f)
        end
      end
    end
    total_price_arr.sum
  end

  def get_calculated_ar_invoice_request(ar_invoice_requests_arr)
    total_price_per_invoice_arr = []
    ar_invoice_requests_arr.each do |ar_invoice_req|
      total_prices_per_inv = 0
      ar_invoice_req.rows.each do |row|
        total_prices_per_inv += row.converted_total_selling_price_with_tax
      end
      total_price_per_invoice_arr.push total_prices_per_inv
    end
    total_price_per_invoice_arr.sum
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

  def invoice_request_status
    [
        'GRPO Pending',
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
        'Cancelled GRPO'
    ]
  end

  def sales_order_statuses
    [
        'Requested',
        'Accounts Approval Pending',
        'Rejected',
        'SAP Rejected',
        'Cancelled',
        'Approved',
        'Order Deleted',
        'Hold by Finance',
        'CO'
    ]
  end

  def recent_sales_orders
    sales_orders
  end

  def select_accounts_person
    account_task_hash = Settings.account_dashboard_task
    parsed_hash = ActiveSupport::JSON.decode(account_task_hash)
    filtered_account_list = Overseer.where(email: parsed_hash.keys).where.not(acl_role: Settings.account_manager.role_id)
    filtered_account_list
  end

  attr_accessor :overseer , :page , :per , :pagination , :inq_status
end
