class Services::Resources::SalesOrders::SaveAndSync < Services::Shared::BaseService
  def initialize(sales_order, now = false)
    @sales_order = sales_order
    @now = now
  end

  def call
    if sales_order.save
      perform_later(sales_order, now)
    end
  end

  def call_later
    if sales_order.persisted?
      if sales_order.remote_uid.blank? && sales_order.order_number.present?
        sap_response_for_so = ::Resources::Order.custom_find(sales_order.order_number)
        if sap_response_for_so.present?
          sales_order.update_attributes(remote_uid: sap_response_for_so['DocEntry'])
        else
          sales_order.update_attributes(remote_uid: ::Resources::Order.create(sales_order))
        end
      end
    end
  end

  attr_accessor :sales_order, :now
end
