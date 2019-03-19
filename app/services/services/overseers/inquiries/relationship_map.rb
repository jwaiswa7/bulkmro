class Services::Overseers::Inquiries::RelationshipMap < Services::Shared::BaseService
  def initialize(inquiry, sales_quotes)
    @inquiry = inquiry
    @sales_quotes = sales_quotes
  end

  def call
    inquiry_json = {
        innerHTML: render_in_service(partial: 'overseers/inquiries/treant_templates/inquiry', locals: {inquiry: inquiry}),
        children: inquiry_sales_quotes(inquiry)
    }
    return inquiry_json
  end

  def inquiry_sales_quotes(inquiry)
    sales_quote_array = Array.new
    sales_quotes.each do |sales_quote|
      assign_block_data('overseers/inquiries/treant_templates/salesquote', sales_quote_array, {sales_quote: sales_quote}, inquiry_sales_orders(sales_quote))
    end
    return sales_quote_array
  end

  def inquiry_sales_orders(sales_quote)
    sales_order_array = Array.new
    sales_quote.sales_orders.each do |sales_order|
      assign_block_data('overseers/inquiries/treant_templates/salesorder', sales_order_array, {sales_order: sales_order}, sales_invoices_and_po_blocks(sales_order))
    end
    return sales_order_array
  end

  def sales_invoices_and_po_blocks(sales_order)
    block_data_array = Array.new
    sales_order.invoices.each do |invoice|
      assign_block_data('overseers/inquiries/treant_templates/invoice', block_data_array, {invoice: invoice}, [])
    end
    sales_order.shipments.each do |shipment|
      assign_block_data('overseers/inquiries/treant_templates/shipment', block_data_array, {shipment: shipment}, [])
    end

    PurchaseOrder.joins(po_request: :sales_order).where(sales_orders: {id: sales_order.id}).each do |purchase_order|
      assign_block_data('overseers/inquiries/treant_templates/purchaseorder', block_data_array, {po: purchase_order}, [])
    end
    return block_data_array
  end


  def assign_block_data(
    partial_template_link,
  data_array,
  locals_data,
  children)
    data_array.push(
        {
            innerHTML: render_in_service(partial: partial_template_link, locals: locals_data),
            children: children
        })
  end

  def render_in_service(*options)
    ApplicationController.new.render_to_string(*options).html_safe
  end

  attr_accessor :inquiry, :sales_quotes

end
