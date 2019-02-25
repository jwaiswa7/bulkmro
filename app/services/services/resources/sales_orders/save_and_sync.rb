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
      if sales_order.draft_uid.present? || sales_order.order_number.present?
        ::Resources::Draft.update(sales_order.draft_uid, sales_order)
      else
        sales_order.update_attributes(draft_uid: ::Resources::Draft.create(sales_order))
      end
    end
  end

  attr_accessor :sales_order
end
