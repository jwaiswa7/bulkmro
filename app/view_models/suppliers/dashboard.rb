class Suppliers::Dashboard
  def initialize(contact, company, params)
    @contact = contact
    @account = contact.account
    @company = company
    @params = params
  end

  def recent_purchase_orders
    indexed_purchase_orders = Services::Suppliers::Finders::PurchaseOrders.new(params.merge(page: 1).merge(per: 5), contact, company)
    indexed_purchase_orders.call.records.try(:reverse)
  end

  def record
    if contact.account_manager?
      account
    else
      contact
    end
  end

  attr_reader :contact, :account, :company, :params
end
