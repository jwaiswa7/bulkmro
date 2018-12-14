module InvoiceRequestHelper
  def invoice_request_status_color(status)
    case status
    when 'Pending GRPO'
      "primary"
    when 'Pending AP Invoice'
      "warning"
    when 'Pending AR Invoice'
      "info"
    when 'Completed AR Invoice Request'
      "success"
    when 'Cancelled AR Invoice'
      "danger"
    end
  end

  def invoice_request_status_badge(status)
    format_badge(status, invoice_request_status_color(status))
  end
end
