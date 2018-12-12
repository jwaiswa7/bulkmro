module SalesOrderHelper
  def sales_order_status_color(status)
    if status == "Requested"
      "warning"
    elsif status == "SAP Approval Pending"
      "warning"
    elsif status == "Rejected"
      "danger"
    elsif status == "SAP Rejected"
      "warning"
    elsif status == "Cancelled"
      "dark"
    elsif status == "Approved"
      "success"
    elsif status == "Order Deleted"
      "dark"
    elsif status == "Closed"
      "dark"
    elsif status == "Hold by Finance"
      "warning"
    else
      "warning"
    end
  end

  def sales_order_customer_status_color(status)
    if status == "Delivered"
      "success"
    else
      "warning"
    end
  end

  def sales_order_status_badge(status)
    format_badge(status, sales_order_status_color(status))
  end

  def sales_order_customer_status_badge(status)
    format_badge(status, sales_order_customer_status_color(status))
  end
end
