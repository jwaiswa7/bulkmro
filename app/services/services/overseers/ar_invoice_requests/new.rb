class Services::Overseers::ArInvoiceRequests::New < Services::Shared::BaseService
  def initialize(params, inward_dispatch)
    @sales_order_id =  params[:so_id] || SalesOrder.decode_id(params[:sales_order_id])
    @inward_dispatches = inward_dispatch
    @current_overseer =   params[:overseer]
  end

  def call
    @sales_order = SalesOrder.where(id: sales_order_id).last
    product_ids_array = []
    sales_order_row_ids_array = []
    # @sales_order_rows = @sales_order.rows.includes(:product).map {|row| { row.product.id => row.id } }
    @sales_order.rows.includes(:product).each do |sales_order_row|
      product_ids_array << sales_order_row.product.id
      sales_order_row_ids_array << sales_order_row.id
    end
    @ar_invoice_request = ArInvoiceRequest.new(overseer: current_overseer, sales_order: @sales_order, inquiry: @sales_order.inquiry)
    inward_dispatches.each do |inward_dispatch|
      inward_dispatch.rows.each do |row|
        is_already_exist = @ar_invoice_request.rows.select { |invoice_row| invoice_row.product_id == row.purchase_order_row.product_id }
        if is_already_exist.empty?
          product_index = product_ids_array.index(row.purchase_order_row.product_id)
          if product_index.present?
            sales_order_row_id = sales_order_row_ids_array[product_index]
          end
          @ar_invoice_request.rows.build(delivered_quantity: row.delivered_quantity, quantity: row.delivered_quantity, inward_dispatch_row_id: row.id, sales_order_id: @sales_order.id, product_id: row.purchase_order_row.product_id, sales_order_row_id: sales_order_row_id)
        else
          is_already_exist.first.quantity += row.delivered_quantity
          is_already_exist.first.delivered_quantity += row.delivered_quantity
        end
      end
    end
    @ar_invoice_request
  end

  attr_accessor :sales_order_id, :inward_dispatches, :current_overseer
end
