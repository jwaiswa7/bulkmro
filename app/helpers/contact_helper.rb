module ContactHelper
  def contact_color(status)
    if status == "active"
      "success"
    else
      "danger"
    end
  end

  def contact_format_badge(status)
    content_tag :span, class: "badge text-uppercase badge-#{contact_color(status)}" do
      content_tag :strong, status.to_s.capitalize
    end
  end
end
