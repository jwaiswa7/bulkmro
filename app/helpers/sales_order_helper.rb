module SalesOrderHelper
  def sales_order_status(status)
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
    format_badge(status, sales_order_status(status))
  end
end
