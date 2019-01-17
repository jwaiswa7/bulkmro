class Services::Overseers::EmailMessages::OrderConfirmationMailer < Services::Shared::BaseService

  def initialize(customer_order,current_overseer = nil)
    @customer_order = customer_order
    @current_overseer = current_overseer
  end

  def call
    if Rails.env.production?
      order_contact = Overseer.find_by_email(customer_order.contact.email)
    else
      order_contact = current_overseer || Overseer.find_by_email('bhargav.trivedi@bulkmro.com')
    end
    template_id = "d-90ffe3b972c14d29ae6992a095638b80"

    template_data = {}
    template_data["name"] = customer_order.contact.to_s
    template_data["order_number"] = customer_order.online_order_number
    template_data["order_date"] = customer_order.created_at
    template_data["shipping_address"] = customer_order.shipping_address.to_multiline_s.gsub('<br>',' ')
    template_data["billing_address"] = customer_order.billing_address.to_multiline_s.gsub('<br>',' ')
    template_data["items"] = []
    customer_order.items.each_with_index do |item,index|
      hash = {}
      hash["sr_no"]=index+1
      hash["product"]=item.customer_product.to_s
      hash["price"]=format_currency(item.customer_product.customer_price.to_f)
      hash["quantity"]=item.quantity
      hash["subtotal"]= format_currency(item.customer_product.customer_price.to_f * item.quantity)
      template_data["items"] << hash
    end

    template_data["tax_rates"] = []
    if customer_order.billing_address.present?
      customer_order.tax_line_items.each do |key, value|
        hash = {}
        hash["tax_rate"] = TaxRateString.for(customer_order.billing_address, customer_order.default_warehouse_address, customer_order.default_warehouse_address, key)
        hash["tax_value"] = format_currency(value)
        template_data["tax_rates"] << hash
      end
    end

    template_data["total_calculated_tax"] = format_currency(customer_order.calculated_total_tax)
    template_data["grand_total"] = format_currency(customer_order.grand_total)

    service =  Services::Overseers::EmailMessages::SendEmail.new
    service.send_email_message(order_contact, template_id, template_data)
  end

  attr_accessor :customer_order, :current_overseer
end