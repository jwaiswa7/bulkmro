class Services::Customers::CustomerOrders::Approval < Services::Shared::BaseService

  def initialize(contact, cart, company, customer_order)
    @contact = contact
    @cart = cart
    @company = company
    @customer_order = customer_order
    @flextronics_company = Company.find 1847
  end

  def call
    if contact.account_manager?
      customer_order.create_approval(contact: contact)
    elsif cart.grand_total.to_f <= 35000 && company.id == flextronics_company.id
      customer_order.create_approval(contact: company.account_manager_contact)
      customer_order.comments.create(customer_order_id: customer_order.id, contact_id: company.account_manager_contact.id, message: 'Approved.', show_to_customer: true)
    end
  end

  attr_accessor :contact, :cart, :company, :customer_order, :flextronics_company
end
