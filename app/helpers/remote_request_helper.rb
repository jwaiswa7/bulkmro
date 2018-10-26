module RemoteRequestHelper
  def remote_status(status)
    if status == "failed"
      "danger"
    elsif status == "success"
      "success"
    elsif status == "pending"
      "warning"
    else
      "warning"
    end
  end

  def remote_request_format_label(status)
    content_tag :span, class: "badge text-uppercase badge-#{remote_status(status)}" do
      content_tag :strong, status.to_s.capitalize
    end
  end
end
