class SalesOrderMailer < ApplicationMailer
  default template_path: "mailers/#{self.name.underscore}"

  def material_dispatched_details_to_customer(email_message)
    @overseer = email_message.overseer
    @contact = email_message.contact
    @inquiry = email_message.inquiry

    standard_email(email_message)
  end

  def material_dispatched_to_customer_notification(email_message)
    @overseer = email_message.overseer
    @contact = email_message.contact
    @inquiry = email_message.inquiry

    attach_files(email_message.files)
    email = htmlized_email(email_message)
    email.delivery_method.settings.merge!(user_name: @overseer.email, password: @overseer.smtp_password)
  end

  def material_delivered_details_to_customer(email_message)
    @overseer = email_message.overseer
    @contact = email_message.contact
    @inquiry = email_message.inquiry

    standard_email(email_message)
  end

  def material_delivered_to_customer_notification(email_message)
    @overseer = email_message.overseer
    @contact = email_message.contact
    @inquiry = email_message.inquiry

    attach_files(email_message.files)
    email = htmlized_email(email_message)
    email.delivery_method.settings.merge!(user_name: @overseer.email, password: @overseer.smtp_password)
  end

  def request_cancel_so_email(email_message)
    @overseer = email_message.overseer
    @sales_order = email_message.sales_order
    @inquiry = email_message.inquiry
    @from = Overseer.find(232) # comment while going to production
    @inside_sales_owner = email_message.inquiry.inside_sales_owner.full_name
    standard_email(email_message)
  end

  def send_request_cancel_so_email(email_message)
    @overseer = Overseer.find(232) # comment while going to production
    # @overseer = email_message.overseer #uncomment while going to production
    @sales_order = email_message.sales_order
    @inquiry = email_message.inquiry
    email = htmlized_email(email_message)
    email.delivery_method.settings.merge!(user_name: @overseer.email, password: @overseer.smtp_password)
  end
end
