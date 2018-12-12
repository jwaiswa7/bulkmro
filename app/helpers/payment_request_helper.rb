module PaymentRequestHelper
  def payment_request_status_color(status)
    case status
    when 'Created'
      "warning"
    when 'Completed'
      "success"
    end
  end

  def payment_request_status_badge(status)
    format_badge(status, payment_request_status_color(status))
  end
end
