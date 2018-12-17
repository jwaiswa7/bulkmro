module PoRequestHelper
  def po_request_status_color(status)
    case status
    when 'Requested'
      "primary"
    when 'PO Created'
      "success"
    when 'Cancelled'
      "success"
    end
  end

  def po_request_status_badge(status)
    format_badge(status, po_request_status_color(status))
  end
end
