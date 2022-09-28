class Services::Overseers::ArInvoiceRequests::New < Services::Shared::BaseService
  def initialize(params, inward_dispatch, delivery_challan)
    @sales_order_id = params[:so_id] || SalesOrder.decode_id(params[:sales_order_id])
    @inward_dispatches = inward_dispatch
    @delivery_challans = delivery_challan
    @current_overseer = params[:overseer]
  end

  def ar_creation_from_inward
    @sales_order = SalesOrder.where(id: sales_order_id).last
    product_ids_array = inward_dispatches.map {|inward_dispatch| inward_dispatch.rows.pluck(:product_id)}.flatten.compact.uniq
    @ar_invoice_request = ArInvoiceRequest.new(overseer: current_overseer, sales_order: @sales_order, inquiry: @sales_order.inquiry)
    ar_invoice_requests = ArInvoiceRequest.where('inward_dispatch_ids @> ?', inward_dispatches.pluck(:id).to_json).where.not(status: 'Cancelled AR Invoice')
    ar_invoice_request_rows = ArInvoiceRequestRow.where(ar_invoice_request_id: ar_invoice_requests.pluck(:id))
    product_ids_array.each do |product_id|
      sales_order_row = @sales_order.rows.where(product_id: product_id).last
      if sales_order_row.present?
        ar_invoice_request_rows_with_product_id = ar_invoice_request_rows.where(product_id: product_id)
        inward_dispatch_rows = InwardDispatchRow.where(inward_dispatch_id: inward_dispatches.pluck(:id), product_id: product_id)
        supplier_delivered_quantity = inward_dispatch_rows.sum(&:delivered_quantity)
        customer_invoiced_quantity = ar_invoice_request_rows_with_product_id.sum(&:delivered_quantity)
        remaining_delivered_quantity = supplier_delivered_quantity - customer_invoiced_quantity
        remaining_delivered_quantity = (remaining_delivered_quantity < 0) ? 0 : remaining_delivered_quantity
        if remaining_delivered_quantity > 0
          @ar_invoice_request.rows.build(delivered_quantity: remaining_delivered_quantity,
              quantity: remaining_delivered_quantity,
              sales_order_id: @sales_order.id,
              product_id: product_id, sales_order_row_id: (sales_order_row.id if sales_order_row.present?)
          )
        end
      end
    end
    @ar_invoice_request
  end

  def ar_creation_from_delivery
    @sales_order = SalesOrder.where(id: sales_order_id).last
    product_ids_array = delivery_challans.map {|delivery_challan| delivery_challan.rows.pluck(:product_id)}.flatten.compact.uniq
    @ar_invoice_request = ArInvoiceRequest.new(overseer: current_overseer, sales_order: @sales_order, inquiry: @sales_order.inquiry)
    ar_invoice_requests = ArInvoiceRequest.where('delivery_challan_ids @> ?', delivery_challans.pluck(:id).to_json).where.not(status: 'Cancelled AR Invoice')
    ar_invoice_request_rows = ArInvoiceRequestRow.where(ar_invoice_request_id: ar_invoice_requests.pluck(:id))
    product_ids_array.each do |product_id|
      sales_order_row = @sales_order.rows.where(product_id: product_id).last
      if sales_order_row.present?
        ar_invoice_request_rows_with_product_id = ar_invoice_request_rows.where(product_id: product_id)
        delivery_challan_rows = DeliveryChallanRow.where(delivery_challan_id: delivery_challans.pluck(:id), product_id: product_id)
        supplier_delivered_quantity = delivery_challan_rows.sum(&:quantity)
        customer_invoiced_quantity = ar_invoice_request_rows_with_product_id.sum(&:delivered_quantity)
        remaining_delivered_quantity = supplier_delivered_quantity - customer_invoiced_quantity
        remaining_delivered_quantity = (remaining_delivered_quantity < 0) ? 0 : remaining_delivered_quantity
        if remaining_delivered_quantity > 0
          @ar_invoice_request.rows.build(delivered_quantity: remaining_delivered_quantity,
                                         quantity: remaining_delivered_quantity,
                                         sales_order_id: @sales_order.id,
                                         product_id: product_id, sales_order_row_id: (sales_order_row.id if sales_order_row.present?)
          )
        end
      end
    end
    @ar_invoice_request
  end

  def ar_creation_from_sales_order
    @sales_order = SalesOrder.where(id: sales_order_id).last
    @ar_invoice_request = ArInvoiceRequest.new(overseer: current_overseer, sales_order: @sales_order, inquiry: @sales_order.inquiry)

    @sales_order.rows.each do |row|
     
      @ar_invoice_request.rows.build( delivered_quantity: row.quantity,
                                      quantity: row.quantity,
                                      sales_order_id: @sales_order.id,
                                      product_id: row.product_id || row.sales_quote_row.product.id, sales_order_row_id: row.id )
    end
    @ar_invoice_request
  end

  attr_accessor :sales_order_id, :inward_dispatches, :current_overseer, :delivery_challans
end
