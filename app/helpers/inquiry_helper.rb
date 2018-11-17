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
    else
      'warning'
    end
  end

  def inquiry_status_badge(status)
    format_badge(status, inquiry_status_color(status)) if status
  end
end