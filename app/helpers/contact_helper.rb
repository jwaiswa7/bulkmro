module ContactHelper
  def contact_status_color(status)
    if status == "active"
      "success"
    else
      "danger"
    end
  end

  def contact_status_badge(status)
    format_badge(status, contact_status_color(status))
  end
end
