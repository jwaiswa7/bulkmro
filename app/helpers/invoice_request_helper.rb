module InvoiceRequestHelper
  def invoice_request_status_color(status)
    case status
    when 'Pending GRPO', 'Pending AP Invoice'
      "warning"
    when 'Pending AR Invoice', 'Completed AR Invoice Request'
      "success"
    when 'AR Invoice Cancelled'
      "danger"
    end
  end

  def invoice_request_status_badge(status)
    format_badge(status, invoice_request_status_color(status))
  end
end
