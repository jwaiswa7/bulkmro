module InquiryHelper
  def inquiry_status_color(status)
    case status.to_sym
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
    when :'SO Rejected by Sales Manager'
      'warning'
    when :'Rejected by Accounts'
      'warning'
    when :'Hold by Accounts'
      'warning'
    when :'Order Lost'
      'danger'
    when :'Regret'
      'danger'
    when :'Inquiry Sent'
      'dark'
    when :'Preparing Quotation'
      'warning'
    when :'Quotation Received'
      'warning'
    when :'Purchase Order Issued'
      'success'
    when :'Purchase Order Revision Pending'
      'danger'
    else
      'warning'
    end
  end

  def inquiry_status_badge(status)
    format_badge(status, inquiry_status_color(status)) if status
  end

  def sales_order_status_color(status)
    case status.to_sym
    when :'Supplier PO: Request Pending'
      'dark'
    when :'Supplier PO: Partially Created'
      'dark'
    when :'Partially Shipped'
      'warning'
    when :'Partially Invoiced'
      'warning'
    when :'Partially Delivered: GRN Pending'
      'danger'
    when :'Partially Delivered: GRN Received'
      'warning'
    when :'Supplier PO: Created'
      'dark'
    when :'Shipped'
      'warning'
    when :'Invoiced'
      'warning'
    when :'Delivered: GRN Pending'
      'danger'
    when :'Delivered: GRN Received'
      'warning'
    when :'Partial Payment Received'
      'warning'
    when :'Payment Received (Closed)'
      'success'
    when :'Cancelled by SAP'
      'dark'
    when :'Short Close'
      'danger'
    when :'Processing'
      'dark'
    when :'Material Ready For Dispatch'
      'warning'
    when :'Order Deleted'
      'danger'
    else
      'warning'
    end
  end

  def sales_order_status_badge(status)
    format_badge(status, sales_order_status_color(status)) if status
  end
end