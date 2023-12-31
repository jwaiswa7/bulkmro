# when :'$0'
# '$2'
module StatusesHelper
  def  status_color(status)
    case status.to_sym
    when :'Processing'
      'status-color-yellow'
    when :'Accounts Approval Pending'
      'status-color-yellow'
    when :'Material Ready For Dispatch'
      'status-color-green'
    when :'Partially Shipped'
      'status-color-green'
    when :'Partially Invoiced'
      'status-color-green'
    when :'Partially Delivered: GRN Pending'
      'status-color-green'
    when :'Partially Delivered: GRN Received'
      'status-color-green'
    when :'Shipped'
      'status-color-green'
    when :'Invoiced'
      'status-color-green'
    when :'In stock'
      'status-color-green'
    when :'Delivered: GRN Pending'
      'status-color-red'
    when :'Delivered: GRN Received'
      'status-color-green'
    when :'Partial Payment Received'
      'status-color-green'
    when :'Full Payment Received'
      'status-color-green'
    when :'Short Closed'
      'status-color-red'
    when :'Cancelled'
      'status-color-red'
    when :'Material Readiness Follow-Up'
      'status-color-blue'
    when :'Material Pickedup'
      'status-color-green'
    when :'Material Partially Pickedup'
      'status-color-green'
    when :'Material Delivered'
      'status-color-green'
    when :'Inward Completed'
      'status-color-green'
    when :'Material Partially Delivered'
      'status-color-green'
    when :'Pending follow-up'
      'status-color-yellow'
    when :'Follow-up for today'
      'status-color-blue'
    when :'Committed Date Breached'
      'status-color-red'
    when :'Committed Date Approaching'
      'status-color-yellow'
    when :'Success'
      'status-color-green'

    # defaults
    when :'Lead by O/S'
      'status-color-blue'
    when :'New Inquiry'
      'status-color-blue'
    when :'Acknowledgement Mail'
      'status-color-blue'
    when :'Cross Reference'
      'status-color-blue'
    when :'Preparing Quotation'
      'status-color-yellow'
    when :'Quotation Sent'
      'status-color-green'
    when :'Follow Up on Quotation'
      'status-color-blue'
    when :'Expected Order'
      'status-color-blue'
    when :'Inquiry Sent'
      'status-color-green'
    when :'Supplier PO: Request Pending'
      'status-color-yellow'
    when :'Supplier PO: Partially Created'
      'status-color-green'
    when :'Supplier PO: Created'
      'status-color-green'
    when :'Processing'
      'status-color-yellow'
    when :'Closed'
      'status-color-grey'
    when :'Order Deleted'
      'status-color-red'
    when :'SO Not Created-Customer PO Awaited'
      'status-color-yellow'
    when :'SO Not Created-Pending Customer PO Revision'
      'status-color-yellow'
    when :'Draft SO for Approval by Sales Manager'
      'status-color-blue'
    when :'SO Draft: Pending Accounts Approval'
      'status-color-yellow'
    when :'Order Won'
      'status-color-green'
    when :'Purchase Order Issued'
      'status-color-green'
    when :'active'
      'status-color-blue'
    when :'Payment Received (Closed)'
      'status-color-green'
    when :'Completed AR Invoice Request'
      'status-color-green'
    when :'Completed'
      'status-color-green'
    when :'Supplier PO: Created Not Sent'
      'status-color-yellow'
    when :'Supplier PO: Created Not Sent'
      'status-color-yellow'
    when :'success'
      'status-color-green'
    when 'Delivered'
      'status-color-green'
    when 'created'
      'status-color-green'
    when :'Approved'
      'status-color-green'
    when :'SO Rejected by Sales Manager'
      'status-color-red'
    when :'Rejected by Accounts'
      'status-color-red'
    when :'Hold by Accounts'
      'status-color-yellow'
    when :'RFQ Sent'
      'yellow'
    when :'PQ Received'
      'yellow'
    when :'Preparing Quotation'
      'status-color-blue'
    when :'Quotation Received'
      'status-color-green'
    when :'Partially Shipped'
      'status-color-green'
    when :'Partially Invoiced'
      'status-color-green'
    when :'Partially Delivered: GRN Received'
      'status-color-green'
    when :'Shipped'
      'status-color-green'
    when :'Invoiced'
      'status-color-green'
    when :'Delivered: GRN Received'
      'status-color-green'
    when :'Partial Payment Received'
      'status-color-green'
    when :'Material Ready For Dispatch'
      'status-color-green'
    when :'Pending AP Invoice'
      'status-color-yellow'
    when :'Pending'
      'status-color-yellow'
    when :'pending'
      'status-color-yellow'
    when :'SAP Rejected'
      'status-color-red'
    when :'SAP Approval Pending'
      'status-color-yellow'
    when :'Hold by Finance'
      'status-color-yellow'
    when :'refunded'
      'status-color-green'
    when :'Order Lost'
      'status-color-red'
    when :'Regret'
      'status-color-red'
    when :'Purchase Order Revision Pending'
      'status-color-yellow'
    when :'Partially Delivered: GRN Pending'
      'status-color-yellow'
    when :'Delivered: GRN Pending'
      'status-color-yellow'
    when :'Short Close'
      'status-color-grey'
    when :'Order Deleted'
      'status-color-red'
    when :'Cancelled AR Invoice' || :'AR Invoice Request Rejected'
      'status-color-red'
    when :'failed'
      'status-color-red'
    when :'Rejected'
      'status-color-red'
    when :'Cancelled'
      'status-color-red'
    when :'Cancelled by SAP'
      'status-color-red'
    when :'GRPO Pending'
      'status-color-yellow'
    when :'Requested'
      'status-color-yellow'
    when :'created'
      'status-color-green'
    when :'Pending AR Invoice'
      'status-color-yellow'
    when :'AR Invoice requested'
      'status-color-yellow'
    when :'authorized'
      'status-color-green'
    when :'captured'
      'status-color-green'
    when :'Supplier PO Sent'
      'status-color-green'
    when :'Supplier PO: Not Sent to Supplier'
      'status-color-red'
    when :'Stock Supplier PO Created'
      'status-color-green'
    when :'Supplier PO Created'
      'status-color-green'
    when :'Stock Requested'
      'status-color-green'
    when :'default'
      'status-color-grey'
    when :'Sync'
      'status-color-green'
    when 'Not Sync'
      'status-color-red'
    when :'To-do'
      'status-color-blue'
    when :'In-progress'
      'status-color-yellow'
    when :'Overdue'
      'status-color-red'
      when :'Completed'
      'status-color-green'
    when :'High'
      'status-color-red'
    when :'Medium'
      'status-color-yellow'
    when :'Low'
      'status-color-blue'
    else
      'status-color-red'
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

  def sap_status(invoiced_qty, total_qty)
    if invoiced_qty == 0
      format_badge("Processing", 'color-yellow')
    elsif invoiced_qty > 0 && invoiced_qty < total_qty
      format_badge("Partially Delivered", 'color-yellow')
    else
      format_badge("Delivered", 'color-green')
    end
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

  # sets the status of the customer order based on the existance of an invoice delivery date
  def customer_order_status(sales_order)

    sales_order.customer_order_status == "Delivered" ? format_badge("Delivered", 'color-green') : format_badge("Processing", 'color-yellow')

  end


  # returns true if the invoice delivery date is present
  def invoice_delivery_date_present?(invoice)
    invoice.delivery_date.present? || invoice.mis_date.present?
  end
end
