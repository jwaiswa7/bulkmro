class SupplierRfqMailer < ApplicationMailer
  default template_path: "mailers/#{self.name.underscore}"

  def request_for_quote_email(email_message, inquiry_product, quantity)
    @overseer = email_message.overseer
    @contact = email_message.contact
    @inquiry = email_message.inquiry
    @supplier_rfq = email_message.supplier_rfq
    @inquiry_product = inquiry_product
    @supplier = Company.find(@supplier_rfq.supplier_id)
    @quantity = quantity
    @inquiry_product_supplier_ids = @supplier_rfq.inquiry_product.inquiry_product_suppliers.pluck(:id)
    standard_email(email_message)
  end

  def send_request_for_quote_email(email_message)
    @overseer = email_message.overseer
    @contact = email_message.contact
    @inquiry = email_message.inquiry
    @supplier_rfq = email_message.supplier_rfq
    email = htmlized_email(email_message)
    email.delivery_method.settings.merge!(user_name: @overseer.email, password: @overseer.smtp_password)
  end
end
