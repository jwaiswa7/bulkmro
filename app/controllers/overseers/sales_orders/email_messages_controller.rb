class Overseers::SalesOrders::EmailMessagesController < Overseers::SalesOrders::BaseController

  def material_dispatched_to_customer
    @email_message = @sales_order.email_messages.build(:overseer => current_overseer, :contact => @inquiry.contact, :inquiry => @inquiry)
    @action = "material_dispatched_to_customer_notification"
    @email_message.assign_attributes(
        :subject => "Ref # #{@inquiry.id} Your Order # #{@inquiry.customer_po_number}- Dispatch Notification",
        :body => SalesOrderMailer.material_dispatched_details_to_customer(@email_message).body.raw_source,
        :auto_attach => true
    )

    authorize @sales_order, :material_dispatched_to_customer_new_email_msg?
    render 'new'
  end

  def material_dispatched_to_customer_notification
    @email_message = @sales_order.email_messages.build(
        :overseer => current_overseer,
        :contact => @inquiry.contact,
        :inquiry => @inquiry
    )

    @email_message.assign_attributes(email_message_params)
    @email_message.assign_attributes(:cc => email_message_params[:cc].split(',').map {|email| email.strip}) if email_message_params[:cc].present?
    @email_message.assign_attributes(:bcc => email_message_params[:cc].split(',').map {|email| email.strip}) if email_message_params[:bcc].present?

    authorize @sales_order, :material_dispatched_to_customer_create_email_msg?

    if @email_message.save
      SalesOrderMailer.material_dispatched_to_customer_notification(@email_message).deliver_now
      redirect_to overseers_sales_orders_path, notice: flash_message(@sales_order, action_name)
    else
      render 'new'
    end
  end

  def material_delivered_to_customer
    @email_message = @sales_order.email_messages.build(:overseer => current_overseer, :contact => @inquiry.contact, :inquiry => @inquiry)
    @action = "material_delivered_to_customer_notification"
    @email_message.assign_attributes(
        :subject => "Ref # #{@inquiry.id} Your Order # #{@inquiry.customer_po_number} - Material Delivery Notification",
        :body => SalesOrderMailer.material_delivered_details_to_customer(@email_message).body.raw_source,
        :auto_attach => true
    )

    authorize @sales_order, :material_delivered_to_customer_new_email_msg?
    render 'new'
  end

  def material_delivered_to_customer_notification
    @email_message = @sales_order.email_messages.build(
        :overseer => current_overseer,
        :contact => @inquiry.contact,
        :inquiry => @inquiry
    )

    @email_message.assign_attributes(email_message_params)
    @email_message.assign_attributes(:cc => email_message_params[:cc].split(',').map {|email| email.strip}) if email_message_params[:cc].present?
    @email_message.assign_attributes(:bcc => email_message_params[:cc].split(',').map {|email| email.strip}) if email_message_params[:bcc].present?

    authorize @sales_order, :material_delivered_to_customer_create_email_msg?

    if @email_message.save
      SalesOrderMailer.material_delivered_to_customer_notification(@email_message).deliver_now
      redirect_to overseers_sales_orders_path, notice: flash_message(@sales_order, action_name)
    else
      render 'new'
    end
  end

  private

  def email_message_params
    params.require(:email_message).permit(
        :subject,
        :body,
        :to,
        :cc,
        :bcc,
        :auto_attach,
        :files => []
    )
  end

end