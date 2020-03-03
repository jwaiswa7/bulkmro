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

  def quote_received_email(email_message, supplier_rfq)
    @overseer = email_message.overseer
    @contact = email_message.contact
    @inquiry = email_message.inquiry
    @supplier_rfq = supplier_rfq
    @supplier = Company.find(@supplier_rfq.supplier_id)
    @inquiry_product_suppliers = @supplier_rfq.inquiry_product_suppliers
    standard_email(email_message)
  end

  def revised_quote_received_email(email_message, supplier_rfq)
    @overseer = email_message.overseer
    @contact = email_message.contact
    @inquiry = email_message.inquiry
    @supplier_rfq = supplier_rfq
    @supplier = Company.find(@supplier_rfq.supplier_id)
    @inquiry_product_suppliers = @supplier_rfq.inquiry_product_suppliers
    standard_email(email_message)
  end

  def send_quote_received_email(email_message)
    email = htmlized_email(email_message)
    email.delivery_method.settings.merge!(user_name: 'itops@bulkmro.com', password: 'dpeloqjmukgkmqim')
  end

  def send_quote_received_email_to_supplier(email_message, supplier_contact, supplier, inquiry, rfq)
    subject = if rfq.supplier_quote_submitted
      "Revised Purchase Quote Received - Inq # #{inquiry.inquiry_number} - RFQ # #{rfq.id} - #{supplier}"
    else
      "Purchase Quote Received - Inq # #{inquiry.inquiry_number} - RFQ # #{rfq.id} - #{supplier}"
    end
    body = render_to_string template: "mailers/supplier_rfq_mailer/quote_received_email_to_supplier", locals: {rfq: rfq, contact: supplier_contact, 
      inquiry_product_suppliers: rfq.inquiry_product_suppliers}
    new_email_message = EmailMessage.new(
      from: inquiry.inside_sales_owner.email,
      to: supplier_contact.email,
      subject: subject,
      body: body
    )
    email = htmlized_email(new_email_message)
    email.delivery_method.settings.merge!(user_name: inquiry.inside_sales_owner.email, password: inquiry.inside_sales_owner.smtp_password)
  end
end
