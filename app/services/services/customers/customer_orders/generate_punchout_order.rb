class Services::Customers::CustomerOrders::GeneratePunchoutOrder < Services::Shared::BaseService
  def initialize(contact, cart, company)
    @contact = contact
    @cart = cart
    @company = company
  end

  def call
    customer_order = contact.customer_orders.create(
      company: company,
      billing_address_id: company.default_billing_address_id,
      shipping_address_id: company.default_shipping_address_id,
      calculated_total: cart.calculated_total,
      calculated_total_tax: cart.calculated_total_tax,
      grand_total: cart.grand_total,
      order_type: 'Punchout'
    )

    cart.items.each do |cart_item|
      customer_order.rows.where(product_id: cart_item.product_id).first_or_create do |row|
        row.quantity = cart_item.quantity
        row.customer_product = cart_item.customer_product
        row.tax_rate_id = cart_item.customer_product&.best_tax_rate&.id
        row.tax_code_id = cart_item.customer_product&.best_tax_code&.id
      end
    end

    customer_order.create_approval(contact: company.account_manager_contact)
    customer_order.comments.create(customer_order_id: customer_order.id, contact_id: company.account_manager_contact.id, message: 'Approved.', show_to_customer: true)

    cart.destroy
  end

  attr_accessor :contact, :cart, :company
end
