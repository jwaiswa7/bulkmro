class Services::Overseers::SalesOrders::NewPoRequests < Services::Shared::BaseService
  def initialize(sales_order, overseer)
    @sales_order = sales_order
    @overseer = overseer
  end

  def call

    @sales_order.rows.each do |row|
      po_requests = @sales_order.po_requests.where(inquiry_id: @sales_order.inquiry.id, supplier_id: row.supplier.id)
      if !po_requests.present?
        po_request = @sales_order.po_requests.create!(inquiry_id: @sales_order.inquiry.id, supplier_id: row.supplier.id, status: :'Draft')
        po_request.rows.first_or_create!(sales_order_row_id: row.id)
      elsif po_requests.first.Draft?
        po_requests.first.rows.where(sales_order_row_id: row.id).first_or_create!
      end
    end
  end
end