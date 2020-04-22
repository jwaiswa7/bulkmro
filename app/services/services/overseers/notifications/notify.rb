class Services::Overseers::Notifications::Notify < Services::Shared::Notifications::BaseService
  def initialize(from, namespace)
    super(from, namespace)
  end

  def send_po_request_update(tos, action, notifiable, url, *msg)
    @action = action; @notifiable = notifiable; @url = url
    @message = "Po Request ##{msg[0]}: #{msg[1]}"
    receivers = Overseer.where(email: tos)
    receivers.uniq.each do | overseer |
      @to = overseer
      send
    end
    inquiry = notifiable.inquiry
    if inquiry.inside_sales_owner.parent.present?
      @message = "Po Request ##{msg[0]}: #{msg[1]} - exec: #{inquiry.inside_sales_owner.to_s}"
      @to = inquiry.inside_sales_owner.parent
    end
  end

  def send_po_request_creation(tos, action, notifiable, url, *msg)
    @action = action; @notifiable = notifiable; @url = url
    @message = "Sales order ##{msg[0]} Supplier PO is requested"
    tos.uniq.each do | to |
      @to = Overseer.find_by_email(to)
      send
    end
  end

  def po_created(action, notifiable, url, *msg)
    @action = action; @notifiable = notifiable; @url = url
    if msg[0].inside_sales_owner.parent.present?
      #msg sent to inside sales owner
      msg_substring = "PO##{notifiable.po_number} for Inquiry##{msg[0].inquiry_number}"
      @message = "#{msg_substring} has been created - exec: #{msg[0].inside_sales_owner.to_s}"
      @to = msg[0].inside_sales_owner.parent
      send
    end
    #msg sent to inside sales owners manager
    @message = "#{msg_substring} has been created"
    @to = msg[0].inside_sales_owner
    send

  end

  def send_ar_invoice_request_update(tos, action, notifiable, url, *msg)
    @action = action; @notifiable = notifiable; @url = url
    @message = msg[0]
    tos.uniq.each do | to |
      @to = Overseer.find_by_email(to)
      send
    end
  end

  def send_stock_po_request_creation(tos, action, notifiable, url, *msg)
    @action = action; @notifiable = notifiable; @url = url
    @message = "Inquiry ##{msg[0]} Stock PO is requested"
    tos.uniq.each do | to |
      @to = Overseer.find_by_email(to)
      send
    end
  end

  def send_company_creation_confirmation(entity, action, notifiable, url, *msg)
    @action = action; @notifiable = notifiable; @url = url
    @message = "#{msg[0]} has been approved and created in Sprint"
    @to = entity.activity.created_by
    send
    @to = notifiable.inside_sales_owner
    send
  end

  def send_contact_creation_confirmation(entity, action, notifiable, url, *msg)
    @action = action; @notifiable = notifiable; @url = url
    @message = "#{msg[0]} has been approved and created in Sprint"
    @to = entity.activity.created_by
    send
  end

  def send_product_import_confirmation(tos, action, notifiable, url, *msg)
    @action = action; @notifiable = notifiable; @url = url
    @message = "#{msg[0]} uploaded for approval in Inquiry ##{msg[1]}"
    tos.uniq.each do | to |
      @to = to
      send
    end
  end

  def send_tax_code(to, action, notifiable, url)
    @to = to; @action = action; @notifiable = notifiable; @url = url
    @message = 'Tax code has been updated!'
    send
  end

  def send_product_comment(to, action, notifiable, url, *msg)
    @to = to; @action = action; @notifiable = notifiable; @url = url

    if msg[0].present?
      @message = "Product #{msg[1]} has been #{msg[0]}"
    else
      @message = "New reply for Product #{msg[1]}"
    end
    @message = "#{@message}: #{msg[2]}" if msg[2].present?
    send
  end

  def send_product_comment_to_manager(to, action, notifiable, url, *msg)
    @to = to; @action = action; @notifiable = notifiable; @url = url

    if msg[0].present?
      @message = "Product #{msg[1]} has been #{msg[0]} - #{msg[3]}"
    else
      @message = "New reply for Product #{msg[1]} - #{msg[3]}"
    end
    @message = "#{@message}: #{msg[2]}" if msg[2].present?
    send
  end

  def send_order_confirmation(to, action, notifiable, url, *msg)
    @action = action; @notifiable = notifiable; @url = url
    @message = "New Order for inquiry ##{msg[0]} awaiting approval"
    @to = to.sales_manager
    send
    @message = "Order for inquiry ##{msg[0]} sent for approval"
    @to = to.outside_sales_owner
    send
    @to = to.inside_sales_owner
    send
  end

  def send_order_comment(to, action, notifiable, url, *msg)
    @to = to; @action = action; @notifiable = notifiable; @url = url
    if msg[0].present?
      @message = "Order for Inquiry ##{msg[1]} has been #{msg[0]}"
    else
      @message = "New reply for order of Inquiry ##{msg[1]}"
    end
    @message = "#{@message}: #{msg[2]}" if msg[2].present?
    send
  end

  def send_sap_order_confirmation(inq, action, notifiable, url, msg)
    @action = action; @notifiable = notifiable; @url = url; @message = msg
    tos = Array.new
    tos << inq.sales_manager
    tos << inq.outside_sales_owner
    tos << inq.inside_sales_owner
    tos.uniq.each do | to |
      @to = to
      send
    end
  end


  def send_so_approved_by_account(sales_order, action, notifiable, url, *msg)
    @action = action; @notifiable = notifiable; @url = url
    inquiry = sales_order.inquiry
    if sales_order.order_number.present?
      msg_substring = 'Order##{sales_order.order_number} '
    else
      msg_substring = 'Order '
    end
    @message = "#{msg_substring}for Inquiry##{inquiry.inquiry_number} has been #{msg[0]} - exec: #{inquiry.inside_sales_owner.to_s}."
    @to = inquiry.sales_manager
    send
    @to = inquiry.inside_sales_owner.parent
    send
    @message = "{msg_substring}for Inquiry##{inquiry.inquiry_number} has been #{msg[0]}."
    @to = inquiry.inside_sales_owner
    send
  end

end
