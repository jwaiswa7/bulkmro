module InquiryHelper
  def inquiry_status_color(status)
    case status.to_sym
    when :'Lead by O/S'
      'secondary'
    when :'Inquiry No. Assigned'
      'secondary'
    when :'Acknowledgement Mail'
      'secondary'
    when :'Cross Reference'
      'dark'
    when :'Supplier RFQ Sent'
      'dark'
    when :'Preparing Quotation'
      'secondary'
    when :'Quotation Sent'
      'success'
    when :'Follow Up on Quotation'
      'warning'
    when :'Expected Order'
      'warning'
    when :'SO Not Created-Customer PO Awaited'
      'warning'
    when :'SO Not Created-Pending Customer PO Revision'
      'warning'
    when :'Draft SO for Approval by Sales Manager'
      'warning'
    when :'SO Draft: Pending Accounts Approval'
      'warning'
    when :'SO Rejected by Sales Manager'
      'danger'
    when :'Rejected by Accounts'
      'danger'
    when :'Hold by Accounts'
      'warning'
    when :'Order Won'
      'success'
    when :'Order Lost'
      'danger'
    when :'Regret'
      'danger'
    else
      'warning'
    end
  end

  def inquiry_status_badge(status)
    format_badge(status, inquiry_status_color(status))
  end
end