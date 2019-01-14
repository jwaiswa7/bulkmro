class Services::Overseers::SalesOrders::NewPoRequests < Services::Shared::BaseService
  def initialize(sales_order, overseer)
    @sales_order = sales_order
    @overseer = overseer
    @po_requests = {}
  end

  def call
    if !@sales_order.po_requests.present?
      po_requests = {}
      @sales_order.rows.each do |row|
        if po_requests[row.supplier.id] == nil
          po_requests[row.supplier.id] = @sales_order.po_requests.build(inquiry_id: @sales_order.inquiry.id, supplier_id: row.supplier.id, status: :'Requested')
        end
        po_requests[row.supplier.id].rows.build(sales_order_row_id: row.id, quantity: row.quantity)
      end
    else
      # TODO Look for po_requests where status is created or requested
      # create po_request for remaining product or remainning quantities
      # If po_request Cancelled then find po_requests with same supplier and add product quantities to existing

      po_requests = {}
      @sales_order.po_requests.not_cancelled.each do |po_request|
        po_request.rows.each do |row|
          debugger
          if row.quantity != row.sales_order_row.quantity
            if po_requests[row.sales_order_row.supplier.id] == nil
              po_requests[row.sales_order_row.supplier.id] = @sales_order.po_requests.build(inquiry_id: @sales_order.inquiry.id, supplier_id: row.sales_order_row.supplier.id, status: :'Requested')
            end
            po_requests[row.sales_order_row.supplier.id].rows.build(sales_order_row_id: row.sales_order_row.id, quantity: (row.sales_order_row.quantity - row.quantity.to_f))
          end
        end
      end
    end
    po_requests
  end

  attr_accessor :po_requests
end