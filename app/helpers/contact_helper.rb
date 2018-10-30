module ContactHelper
  def contact_color(status)
    if status == "active"
      "success"
    else
      "danger"
    end
  end

  def contact_format_badge(status)
    format_badge(status, contact_color(status))
  end
end
