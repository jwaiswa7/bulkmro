module StatusesHelper
  def statuses_color(status)
    case status.to_sym
    when :'Lead by O/S', :'New Inquiry', :'Acknowledgement Mail', :'Cross Reference', :'Supplier RFQ Sent', :'Preparing Quotation', :'Quotation Sent', :'Follow Up on Quotation', :'Expected Order', :'Inquiry Sent', :'Supplier PO: Request Pending', :'Supplier PO: Partially Created', :'Supplier PO: Created', :'Cancelled by SAP', :'Processing', :'Closed', :'Order Deleted'
      'dark'
    when :'SO Not Created-Customer PO Awaited', :'SO Not Created-Pending Customer PO Revision', :'Draft SO for Approval by Sales Manager', :'SO Draft: Pending Accounts Approval', :'Order Won', :'Purchase Order Issued', :'active', :'Payment Received (Closed)', :'Completed AR Invoice Request', :'Completed', :'PO Created', :'Cancelled', 'success', 'Delivered', :'Approved'
      'success'
    when :'SO Rejected by Sales Manager', :'Rejected by Accounts', :'Hold by Accounts', :'Preparing Quotation', :'Quotation Received', :'Partially Shipped', :'Partially Invoiced', :'Partially Delivered: GRN Received', :'Shipped', :'Invoiced', :'Delivered: GRN Received', :'Partial Payment Received', :'Material Ready For Dispatch', :'Pending AP Invoice', :'Pending', :'pending', :'SAP Rejected', :'SAP Approval Pending', :'Hold by Finance'
      'warning'
    when :'Order Lost', :'Regret', :'Purchase Order Revision Pending', :'Partially Delivered: GRN Pending', :'Delivered: GRN Pending', :'Short Close', :'Order Deleted', :'Cancelled AR Invoice', :'failed', :'Rejected'
      'danger'
    when :'Pending GRPO', :'Requested'
      'primary'
    when :'Pending AR Invoice'
      'info'
    else
      'danger'
    end
  end

  def status_badge(status)
    format_badge(status, statuses_color(status)) if status
  end
end