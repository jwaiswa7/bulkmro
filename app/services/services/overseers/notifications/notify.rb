class Services::Overseers::Notifications::Notify < Services::Shared::Notifications::BaseService
  def initialize(from, namespace)
    super(from, namespace)
  end

  def send_po_request_creation(tos, action, notifiable, url, *msg)
    @action = action; @notifiable = notifiable; @url = url
    @message = "Sales order ##{msg[0]} Supplier PO is requested"
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
    @message = "Tax code has been updated!"
    send
  end

  def send_product_comment(to, action, notifiable, url, *msg)
    @to = to; @action = action; @notifiable = notifiable; @url = url

    if msg[0].present?
      @message = "Product #{msg[1]} has been #{msg[0]}"
    else
      @message = "New reply for Product #{msg[1]}"
    end
    @message = "#{@message.to_s}: #{msg[2]}" if msg[2].present?
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
    @message = "#{@message.to_s}: #{msg[2]}" if msg[2].present?
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
end
