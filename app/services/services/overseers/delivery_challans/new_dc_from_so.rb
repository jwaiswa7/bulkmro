class Services::Overseers::DeliveryChallans::NewDcFromSo < Services::Shared::BaseService
  def initialize(params, overseer)
    @params = params
    @sales_order = SalesOrder.find(params[:sales_order_id]) if params[:sales_order_id].present?
    @inquiry = Inquiry.find(params[:inquiry_id])
    @overseer = overseer
  end

  def call
    if params[:purpose] == 'Regular Flow'
      delivery_challan = sales_order.delivery_challans.build(
        inquiry_id: inquiry.id,
        customer_po_number: sales_order&.inquiry&.customer_po_number,
        customer_bill_from: sales_order.serialized_billing_address,
        customer_ship_from: sales_order.serialized_shipping_address,
        supplier_bill_from: inquiry&.bill_from,
        supplier_ship_from: inquiry&.ship_from,
        customer_order_date: inquiry&.customer_order_date,
        sales_order_date: sales_order&.mis_date,
        overseer: overseer,
        purpose: params[:purpose]
      )

      sales_order.rows.each do |row|
        delivery_challan.rows.where(sales_order_row_id: row.id).first_or_initialize(
          inquiry_product: row&.inquiry_product,
          product: row&.product,
          quantity: row.quantity,
          overseer: overseer
        )
      end
    else
      delivery_challan = inquiry.delivery_challans.build(
        inquiry_id: inquiry.id,
        customer_po_number: inquiry&.customer_po_number,
        customer_bill_from: inquiry&.billing_address,
        customer_ship_from: inquiry&.shipping_address,
        supplier_bill_from: inquiry&.bill_from,
        supplier_ship_from: inquiry&.ship_from,
        customer_order_date: inquiry&.customer_order_date,
        overseer: overseer,
        purpose: params[:purpose]
      )

      inquiry.inquiry_products.each do |inquiry_product|
        delivery_challan.rows.where(inquiry_product_id: inquiry_product.id).first_or_initialize(
          product: row&.product,
          quantity: row.quantity,
          overseer: overseer
        )
      end
    end

    delivery_challan
  end

  private

    attr_accessor :params, :sales_order, :overseer, :inquiry
end
