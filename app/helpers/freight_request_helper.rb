module FreightRequestHelper
  def freight_request_status_color(status)
    case status
    when 'Requested'
      "warning"
    when 'Completed'
      "success"
    when 'Cancelled'
      "danger"
    end
  end

  def freight_request_status_badge(status)
    format_badge(status, freight_request_status_color(status))
  end
end
