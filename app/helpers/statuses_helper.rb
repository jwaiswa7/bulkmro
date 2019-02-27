# when :'$0'
# '$2'
module StatusesHelper
  def status_color(status)
    case status.to_sym
    when :'Processing'
      'color-light-blue'
    when :'Material Ready For Dispatch'
      'color-dark-blue'
    when :'Partially Shipped'
      'color-light-yellow'
    when :'Partially Invoiced'
      'color-light-yellow'
    when :'Partially Delivered: GRN Pending'
      'color-red'
    when :'Partially Delivered: GRN Received'
      'color-light-green'
    when :'Shipped'
      'color-yellow'
    when :'Invoiced'
      'color-yellow'
    when :'In stock'
      'color-yellow'
    when :'Delivered: GRN Pending'
      'color-red'
    when :'Delivered: GRN Received'
      'color-light-green'
    when :'Partial Payment Received'
      'color-green'
    when :'Full Payment Received'
      'color-dark-green'
    when :'Short Closed'
      'color-grey'
    when :'Cancelled'
      'color-grey'

    # defaults
    when :'Lead by O/S'
      'dark'
    when :'New Inquiry'
      'dark'
    when :'Acknowledgement Mail'
      'dark'
    when :'Cross Reference'
      'dark'
    when :'Supplier RFQ Sent'
      'dark'
    when :'Preparing Quotation'
      'dark'
    when :'Quotation Sent'
      'dark'
    when :'Follow Up on Quotation'
      'dark'
    when :'Expected Order'
      'dark'
    when :'Inquiry Sent'
      'dark'
    when :'Supplier PO: Request Pending'
      'dark'
    when :'Supplier PO: Partially Created'
      'dark'
    when :'Supplier PO: Created'
      'dark'
    when :'Processing'
      'dark'
    when :'Closed'
      'dark'
    when :'Order Deleted'
      'dark'
    when :'SO Not Created-Customer PO Awaited'
      'success'
    when :'SO Not Created-Pending Customer PO Revision'
      'success'
    when :'Draft SO for Approval by Sales Manager'
      'success'
    when :'SO Draft: Pending Accounts Approval'
      'success'
    when :'Order Won'
      'success'
    when :'Purchase Order Issued'
      'success'
    when :'active'
      'success'
    when :'Payment Received (Closed)'
      'success'
    when :'Completed AR Invoice Request'
      'success'
    when :'Completed'
      'success'
    when :'PO Created'
      'success'
    when :'success'
      'success'
    when 'Delivered'
      'success'
    when 'created'
      'success'
    when :'Approved'
      'success'
    when :'SO Rejected by Sales Manager'
      'warning'
    when :'Rejected by Accounts'
      'warning'
    when :'Hold by Accounts'
      'warning'
    when :'Preparing Quotation'
      'warning'
    when :'Quotation Received'
      'warning'
    when :'Partially Shipped'
      'warning'
    when :'Partially Invoiced'
      'warning'
    when :'Partially Delivered: GRN Received'
      'warning'
    when :'Shipped'
      'warning'
    when :'Invoiced'
      'warning'
    when :'Delivered: GRN Received'
      'warning'
    when :'Partial Payment Received'
      'warning'
    when :'Material Ready For Dispatch'
      'warning'
    when :'Pending AP Invoice'
      'warning'
    when :'Pending'
      'warning'
    when :'pending'
      'warning'
    when :'SAP Rejected'
      'warning'
    when :'SAP Approval Pending'
      'warning'
    when :'Hold by Finance'
      'warning'
    when :'refunded'
      'color-yellow'
    when :'Order Lost'
      'danger'
    when :'Regret'
      'danger'
    when :'Purchase Order Revision Pending'
      'danger'
    when :'Partially Delivered: GRN Pending'
      'danger'
    when :'Delivered: GRN Pending'
      'danger'
    when :'Short Close'
      'danger'
    when :'Order Deleted'
      'danger'
    when :'Cancelled AR Invoice'
      'danger'
    when :'failed'
      'danger'
    when :'Rejected'
      'danger'
    when :'Cancelled'
      'danger'
    when :'Cancelled by SAP'
      'danger'
    when :'Pending GRPO'
      'primary'
    when :'Requested'
      'primary'
    when :'created'
      'success'
    when :'Pending AR Invoice'
      'info'
    when :'authorized'
      'info'
    when :'captured'
      'success'
    when :'Supplier PO Sent'
      'success'
    when :'Supplier PO: Not Sent to Supplier'
      'danger'
    when :'Stock Supplier PO Created'
      'success'
    when :'Stock Requested'
      'warning'
    else
      'danger'
    end
  end

  def format_badge(text, color)
    if text.to_s != ''
      content_tag :span, class: "badge badge-wrap text-uppercase badge-#{color}" do
        content_tag :strong, text.to_s.capitalize
      end
    end
  end

  def status_count(klass, status)
    case klass.name.to_sym
    when :SalesOrder
      if klass.statuses.keys.include?status
        klass.where(status: status).or(klass.where(legacy_request_status: status)).count
      else
        klass.where(remote_status: status).count
      end
    when :PurchaseOrder
      klass.all.map(&:metadata_status).count(status)
    else
      klass.where(status: status).count;
    end
  end

  def status_badge(status)
    format_badge(status, status_color(status)) if status
  end

  def due_badge(due_in_days, text)
    if due_in_days == 0
      format_badge(text, 'color-red')
    elsif due_in_days < 0
      format_badge(text, 'danger')
    elsif due_in_days <= 2
      format_badge(text, 'color-yellow')
    elsif due_in_days <= 5
      format_badge(text, 'color-dark-blue')
    else
      format_badge(text, 'color-dark-green')
    end
  end
end
