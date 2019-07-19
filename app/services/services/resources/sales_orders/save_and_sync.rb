class Services::Resources::SalesOrders::SaveAndSync < Services::Shared::BaseService
  def initialize(sales_order)
    @sales_order = sales_order
  end

  def call
    if sales_order.save
      perform_later(sales_order)
    end
  end

  def call_later
    if sales_order.persisted?
      if sales_order.remote_uid.blank? && sales_order.order_number.present?
        sales_order.update_attributes(remote_uid: ::Resources::Order.create(sales_order))
      end
    end
  end

  attr_accessor :sales_order
end
