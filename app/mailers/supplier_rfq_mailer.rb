class SupplierRfqMailer < ApplicationMailer
  default template_path: "mailers/#{self.name.underscore}"

  def request_for_quote_email(email_message, supplier_rfq)
    @overseer = email_message.overseer
    @contact = email_message.contact
    @inquiry = email_message.inquiry
    @supplier_rfq = supplier_rfq
    @supplier = Company.find(@supplier_rfq.supplier_id)
    inquiry_product_supplier_ids = @supplier_rfq.inquiry_product_suppliers.pluck(:id)
    inquiry_product_ids = InquiryProductSupplier.where(id: inquiry_product_supplier_ids).pluck(:inquiry_product_id).uniq
    @inquiry_products = InquiryProduct.where(id: inquiry_product_ids)
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
