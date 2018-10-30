module RemoteRequestHelper
  def remote_request_status_color(status)
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

  def remote_request_status_badge(status)
    format_badge(status, remote_request_status_color(status))
  end
end
