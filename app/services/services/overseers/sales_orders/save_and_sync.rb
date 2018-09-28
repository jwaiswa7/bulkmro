class Services::Overseers::SalesOrders::SaveAndSync < Services::Shared::BaseService

  def initialize(sales_order)
    @sales_order = sales_order
  end

  def call
    if Rails.env.development?
      call_later
    else
      perform_later(sales_order)
    end
  end

  def call_later

    if sales_order.persisted?
      if sales_order.doc_number.present?
        Resources::Draft.update(sales_order.doc_number, sales_order)
      else
        sales_order.doc_number = Resources::Draft.create(sales_order)
        sales_order.save
      end
    end
  end

  attr_accessor :sales_order
end