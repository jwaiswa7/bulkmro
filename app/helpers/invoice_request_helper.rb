module InvoiceRequestHelper
  def invoice_request_status_color(status)
    case status
    when 'GRPO Pending', 'AP Invoice Pending'
      "warning"
    when 'AR Invoice Pending', 'AR Invoice Generated'
      "success"
    when 'AR Invoice Cancelled'
      "danger"
    end
  end

  def invoice_request_status_badge(status)
    format_badge(status, invoice_request_status_color(status))
  end
end
