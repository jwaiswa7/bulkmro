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
      @message = "Po Request ##{msg[0]}: #{msg[1]} - exec: #{inquiry.inside_sales_owner}"
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
    msg_substring = "PO##{notifiable.po_number} for Inquiry##{msg[0].inquiry_number}"
    if msg[0].inside_sales_owner.parent.present?
      # msg sent to inside sales owner
      @message = "#{msg_substring} has been created - exec: #{msg[0].inside_sales_owner}"
      @to = msg[0].inside_sales_owner.parent
      send
    end
    # msg sent to inside sales owners manager
    @message = "#{msg_substring} has been created"
    @to = msg[0].inside_sales_owner
    send
  end

  def send_ar_invoice_request_update(tos, sender, action, notifiable, url, *msg)
    @action = action; @notifiable = notifiable; @url = url
    @message = msg[0]
    @to = Overseer.find_by_email(sender)
    send
    manager = []
    receivers = Overseer.where(email: tos)
    receivers.uniq.each do | overseer |
      manager << overseer.parent if overseer.parent.present?
      @to = overseer
      send
    end
    manager.uniq.each do |parent|
      @to = parent
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
      if msg[0] == 'approve'
        @message = "Product #{msg[1]} has been approved"
      elsif msg[0] == 'reject'
        @message = "Product #{msg[1]} has been rejected"
      else
        @message = "Product #{msg[1]} has been #{msg[0]}"
        @message = "#{@message}: #{msg[2]}" if msg[2].present?
      end
    else
      @message = "New reply for Product #{msg[1]}"
      @message = "#{@message}: #{msg[2]}" if msg[2].present?
    end

    send
  end

  def send_product_comment_to_manager(to, action, notifiable, url, *msg)
    @to = to; @action = action; @notifiable = notifiable; @url = url

    if msg[0].present?
      if msg[0] == 'approve'
        @message = "Product #{msg[1]} has been approved - exec: #{msg[3]}"
      elsif msg[0] == 'reject'
        @message = "Product #{msg[1]} has been rejected - exec: #{msg[3]}"
      else
        @message = "Product #{msg[1]} has been #{msg[0]} - exec: #{msg[3]}"
        @message = "#{@message}: #{msg[2]}" if msg[2].present?
      end
    else
      @message = "New reply for Product #{msg[1]} - exec: #{msg[3]}"
      @message = "#{@message}: #{msg[2]}" if msg[2].present?
    end
    send
  end

  def send_order_confirmation(to, action, notifiable, url, *msg)
    @action = action; @notifiable = notifiable; @url = url
    @message = "New Order for inquiry ##{msg[0]} awaiting approval"
    @to = to.sales_manager
    send
    tos = Services::Overseers::Notifications::Recipients.so_approval_rejection_notifiers
    manager = []
    receivers = Overseer.where(email: tos)
    receivers.uniq.each do | overseer |
      manager << overseer.parent if overseer.parent.present?
      @to = overseer
      send
    end
    manager.uniq.each do |parent|
      @to = parent
      send
    end
    @message = "Order for inquiry ##{msg[0]} sent for approval"
    @to = to.outside_sales_owner
    send
    @to = to.inside_sales_owner
    send
  end

  def send_order_comment(to, action, notifiable, url, *msg)
    @to = to; @action = action; @notifiable = notifiable; @url = url
    if msg[0].present?
      if  msg[0] == 'approve'
        @message = "Order for Inquiry ##{msg[1]} has been approved."
      elsif msg[0] == 'reject'
        @message = "Order for Inquiry ##{msg[1]} has been rejected."
      else
        @message = "Order for Inquiry ##{msg[1]} has been #{msg[0]}"
        @message = "#{@message}: #{msg[2]}" if msg[2].present?
      end
    else
      @message = "New reply for order of Inquiry ##{msg[1]}"
      @message = "#{@message}: #{msg[2]}" if msg[2].present?
    end
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
      msg_substring = "Order ##{sales_order.order_number} "
    else
      msg_substring = 'Order '
    end
    @message = "#{msg_substring}for Inquiry##{inquiry.inquiry_number} has been #{msg[0]} - exec: #{inquiry.inside_sales_owner}."
    @to = inquiry.sales_manager
    send
    @to = inquiry.inside_sales_owner.parent
    send
    @message = "#{msg_substring}for Inquiry##{inquiry.inquiry_number} has been #{msg[0]}."
    @to = inquiry.inside_sales_owner
    send
    tos = Services::Overseers::Notifications::Recipients.so_approval_rejection_notifiers
    manager = []
    receivers = Overseer.where(email: tos)
    receivers.uniq.each do |overseer|
      manager << overseer.parent if overseer.parent.present?
      @to = overseer
      send
    end
    manager.uniq.each do |parent|
      @to = parent
      send
    end
  end

  def send_inquiry_status_changed(to, action, notificable, url, *msg)
    @action = action; @notifiable = notificable; @url = url
    @message = "Inquiry ##{notificable.inquiry_number} - status updated to #{msg[0]} "
    @to = to
    send
    if to.parent.present?
      @message = "Inquiry ##{notificable.inquiry_number} - status updated to #{msg[0]} - exec: #{to}"
      @to = to.parent
      send
    end
  end

  def send_invoice_request_update(tos, sender, action, notifiable, url, *msg)
    @action = action; @notifiable = notifiable; @url = url
    @message = msg[0]
    @to = Overseer.find_by_email(sender)
    send
    manager = []
    receivers = Overseer.where(email: tos)
    receivers.uniq.each do |overseer|
      manager << overseer.parent if overseer.parent.present?
      @to = overseer
      send
    end
    manager.uniq.each do |parent|
      @to = parent
      send
    end
  end

  def send_activity_created(activity, action, notifiable, url)
      @action = action; @notifiable = notifiable; @url = url
      @message = "#{activity.created_by.name} created an activity # #{activity.activity_number}"
      if activity.overseer_ids.count > 0
        activity.overseers.uniq.each do | to |
          @to = to
          send
        end
      elsif activity.created_by.parent.present?
        @to = activity.created_by.parent
        send
      end
    end

    def send_task_comment(to, action, notifiable, url, msg)
      @action = action
      @notifiable = notifiable
      @url = url
      @message = msg
      @to = Overseer.find(to)
      send
    end

end
