class Services::Overseers::DeliveryChallans::RelationshipMap < Services::Shared::BaseService
  def initialize(delivery_challan)
    @delivery_challan = delivery_challan
    @inquiry = delivery_challan.inquiry
    if delivery_challan.sales_order.sales_quote.present?
      @sales_quote = delivery_challan.sales_order.sales_quote
    end
    if delivery_challan.sales_order.present?
      @sales_order = delivery_challan.sales_order
    end
    if delivery_challan.ar_invoice_request.present?
      @ar_invoice_req = delivery_challan.ar_invoice_request
    end
  end

  def call
    {
        innerHTML: render_in_service(partial: 'overseers/inquiries/treant_templates/inquiry', locals: {inquiry: inquiry}),
        children: make_delivery_challan
    }
  end

  def make_delivery_challan
    if sales_order.present?
      children = inquiry_sales_quotes
    else
      children = inquiry_delivery_challan
    end
    children
  end

  def inquiry_sales_quotes
    sales_quote_array = Array.new
      assign_block_data('overseers/inquiries/treant_templates/salesquote', sales_quote_array, {sales_quote: sales_quote}, inquiry_sales_orders)
    sales_quote_array
  end

  def inquiry_sales_orders
    sales_order_array = Array.new
      assign_block_data('overseers/inquiries/treant_templates/salesorder', sales_order_array, {sales_order: sales_order}, inquiry_delivery_challan)
    sales_order_array
  end

  def inquiry_delivery_challan
    delivery_challan_array = Array.new
    assign_block_data('overseers/inquiries/treant_templates/deliverychallan', delivery_challan_array, {delivery_challan: delivery_challan},sales_invoices)
    delivery_challan_array
  end

  def sales_invoices
    block_data_array = Array.new
    if delivery_challan.ar_invoice_request.present?
      invoice = ar_invoice_req.sales_invoice
      assign_block_data('overseers/inquiries/treant_templates/invoice', block_data_array, {invoice: invoice}, [])
    end
    sales_order.shipments.each do |shipment|
      assign_block_data('overseers/inquiries/treant_templates/shipment', block_data_array, {shipment: shipment}, [])
    end

    # PurchaseOrder.joins(po_request: :sales_order).where(sales_orders: {id: sales_order.id}).each do |purchase_order|
    #   assign_block_data('overseers/inquiries/treant_templates/purchaseorder', block_data_array, {po: purchase_order}, [])
    # end
    block_data_array
  end

  def assign_block_data(partial_template_link, data_array, locals_data, children)
    json = {
        innerHTML: render_in_service(partial: partial_template_link, locals: locals_data),
        children: children
    }
    data_array.push(json)
  end


  def render_in_service(*options)
    ApplicationController.new.render_to_string(*options).html_safe
  end

  attr_accessor :inquiry, :sales_quote, :ar_invoice_req, :delivery_challan, :sales_order
end