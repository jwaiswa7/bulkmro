module SalesOrderHelper
  def status(status)
    if status == "requested"
      "warning"
    elsif status == "SAP Approval Pending"
      "warning"
    elsif status == "rejected"
      "danger"
    elsif status == "SAP Rejected"
      "warning"
    elsif status == "Cancelled"
      "dark"
    elsif status == "approved"
      "success"
    elsif status == "Order Deleted"
      "dark"
    elsif status == "Hold by Finance"
      "warning"
    else
      "warning"
    end
  end

  def sales_order_format_label(status)
    content_tag :span, class: "badge text-uppercase badge-#{status(status)}" do
      content_tag :strong, status.to_s.capitalize
    end
  end
end
