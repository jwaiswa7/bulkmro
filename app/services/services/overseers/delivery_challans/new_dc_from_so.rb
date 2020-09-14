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

      generate_from_so_rows(sales_order, delivery_challan)
      
    else
      delivery_challan = inquiry.delivery_challans.build(
        inquiry_id: inquiry.id,
        sales_order_id: (sales_order.id if sales_order.present?),
        customer_po_number: inquiry&.customer_po_number,
        customer_bill_from: (sales_order.present? ? sales_order.serialized_billing_address : inquiry&.billing_address),
        customer_ship_from: (sales_order.present? ? sales_order.serialized_shipping_address : inquiry&.shipping_address),
        supplier_bill_from: inquiry&.bill_from,
        supplier_ship_from: inquiry&.ship_from,
        customer_order_date: inquiry&.customer_order_date,
        overseer: overseer,
        purpose: params[:purpose],
        reason: 40,
        sales_order_date: (sales_order&.mis_date if sales_order.present?)
      )

      sales_order.present? ? generate_from_so_rows(sales_order, delivery_challan) : generate_from_inquiry_products(inquiry, delivery_challan)
      
    end

    delivery_challan
  end

  private

    def generate_from_so_rows(sales_order, delivery_challan)
      sales_order.rows.each do |row|
        delivery_challan.rows.where(sales_order_row_id: row.id).first_or_initialize(
          inquiry_product: row&.inquiry_product,
          product: row&.product,
          quantity: row.quantity,
          overseer: overseer
        )
      end
    end

    def generate_from_inquiry_products(inquiry, delivery_challan)
      inquiry.inquiry_products.each do |inquiry_product|
        delivery_challan.rows.where(inquiry_product_id: inquiry_product.id).first_or_initialize(
          product: inquiry_product&.product,
          quantity: inquiry_product&.quantity,
          overseer: overseer
        )
      end
    end

    attr_accessor :params, :sales_order, :overseer, :inquiry
end
