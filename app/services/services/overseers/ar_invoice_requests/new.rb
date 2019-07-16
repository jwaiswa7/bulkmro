class Services::Overseers::ArInvoiceRequests::New < Services::Shared::BaseService
  def initialize(params, inward_dispatch)
    @sales_order_id = params[:so_id] || SalesOrder.decode_id(params[:sales_order_id])
    @inward_dispatches = inward_dispatch
    @current_overseer = params[:overseer]
  end

  def call
    @sales_order = SalesOrder.where(id: sales_order_id).last
    product_ids_array = inward_dispatches.map{|inward_dispatch| inward_dispatch.rows.pluck(:product_id)}.flatten.compact.uniq
    @sales_order_rows = SalesOrderRow.where(sales_order_id: sales_order_id,product_id: product_ids_array)
    @ar_invoice_request = ArInvoiceRequest.new(overseer: current_overseer, sales_order: @sales_order, inquiry: @sales_order.inquiry)
    @sales_order_rows.each do |sales_order_row|
      product_id = sales_order_row.product_id
      inward_dispatche_rows = InwardDispatchRow.where(inward_dispatch_id: inward_dispatches.pluck(:id), product_id: product_id)
      supplier_delivered_quantity = inward_dispatche_rows.sum(&:delivered_quantity)
      ar_invoice_request_rows = ArInvoiceRequestRow.where(sales_order_id: sales_order_id, product_id: product_id).joins(:ar_invoice_request).where.not(ar_invoice_requests: {status: "Cancelled AR Invoice"})
      customer_invoiced_quantity = ar_invoice_request_rows.sum(&:delivered_quantity)
      remaining_delivered_quantity = supplier_delivered_quantity - customer_invoiced_quantity
      remaining_delivered_quantity = (remaining_delivered_quantity < 0) ? 0 : remaining_delivered_quantity
      @ar_invoice_request.rows.build(delivered_quantity: remaining_delivered_quantity, quantity: remaining_delivered_quantity, sales_order_id: @sales_order.id, product_id: product_id, sales_order_row_id: sales_order_row.id)
    end
    @ar_invoice_request
  end

  attr_accessor :sales_order_id, :inward_dispatches, :current_overseer
end
