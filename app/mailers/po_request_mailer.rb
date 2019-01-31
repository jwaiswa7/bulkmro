class PoRequestMailer < ApplicationMailer
  default :template_path => "mailers/#{self.name.underscore}"

  def purchase_order_details(email_message)
    @contact = email_message.contact
    @inquiry = email_message.inquiry
    @overseer = email_message.overseer
    @purchase_order = email_message.purchase_order
    @sales_order = email_message.sales_order

    standard_email(email_message)
  end

  def send_supplier_notification(email_message)
    @overseer = email_message.overseer
    @contact = email_message.contact
    @inquiry = email_message.inquiry
    @purchase_order = email_message.purchase_order
    @sales_order = email_message.sales_order

    attach_files(email_message.files)
    email = htmlized_email(email_message)
    email.delivery_method.settings.merge!({user_name: @overseer.email, password: @overseer.smtp_password})
  end

  def dispatch_supplier_delayed(email_message)
    @overseer = email_message.overseer
    @inquiry = email_message.inquiry

    standard_email(email_message)
  end


  def send_dispatch_from_supplier_delayed_notification(email_message)
    @overseer = email_message.overseer
    @contact = email_message.contact
    @inquiry = email_message.inquiry

    email = htmlized_email(email_message)
    email.delivery_method.settings.merge!({user_name: @overseer.email, password: @overseer.smtp_password})
  end

end