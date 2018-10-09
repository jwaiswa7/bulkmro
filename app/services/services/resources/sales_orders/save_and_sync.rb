class Services::Resources::SalesOrders::SaveAndSync < Services::Shared::BaseService

  def initialize(sales_order)
    @sales_order_draft = sales_order
  end

  def call
    if sales_order.save!
      perform_later(sales_order_draft)
    end
  end

  def call_later
    if sales_order_draft.persisted?
      if sales_order_draft.doc_number.present?
        ::Resources::Draft.update(sales_order_draft.doc_number, sales_order_draft)
      else
        sales_order_draft.doc_number = ::Resources::Draft.create(sales_order_draft)
        sales_order_draft.save
      end
    end
  end

  attr_accessor :sales_order_draft
end