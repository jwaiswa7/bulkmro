class Services::Overseers::DeliveryChallans::NewDcFromSo < Services::Shared::BaseService
  def initialize(params, overseer)
    @params = params
    @sales_order = SalesOrder.find(params[:sales_order_id]) if params[:sales_order_id].present?
    @inquiry = Inquiry.find(params[:inquiry_id])
    @inward_dispatch = InwardDispatch.find(params[:inward_dispatch_id]) if params[:inward_dispatch_id].present?
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
        purpose: params[:purpose],
        inward_dispatch_id: inward_dispatch&.id,
        created_from: params[:created_from]
      )
      
      inward_dispatch.present? ? generate_from_inward_dispatch_rows(inward_dispatch, delivery_challan) : generate_from_so_rows(sales_order, delivery_challan)
      
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
        sales_order_date: (sales_order&.mis_date if sales_order.present?),
        created_from: params[:created_from]
      )

      sales_order.present? ? generate_from_so_rows(sales_order, delivery_challan) : generate_from_inquiry_products(inquiry, delivery_challan)
      
    end

    delivery_challan
  end

  private

    def generate_from_so_rows(sales_order, delivery_challan)
      sales_order.rows.each do |row|
        delivery_challan.rows.build do |dc_row|
          dc_row.sales_order_row_id = row.id
          dc_row.inquiry_product = row&.inquiry_product
          dc_row.product = row&.product
          dc_row.total_quantity = row.quantity
          dc_row.quantity = dc_row.get_quantity
          dc_row.overseer = overseer
        end
      end
    end

    def generate_from_inquiry_products(inquiry, delivery_challan)
      inquiry.inquiry_products.each do |inquiry_product|
        delivery_challan.rows.build do |dc_row|
          dc_row.inquiry_product_id = inquiry_product.id
          dc_row.product = inquiry_product&.product
          dc_row.total_quantity = inquiry_product&.quantity
          dc_row.quantity = dc_row.get_quantity
          dc_row.overseer = overseer
        end
      end
    end

    def generate_from_inward_dispatch_rows(inward_dispatch, delivery_challan)
      inward_dispatch.rows.each do |row|
        delivery_challan.rows.build do |dc_row|
          dc_row.inward_dispatch_row_id = row.id
          dc_row.product = row&.product
          dc_row.inquiry_product = row&.product&.inquiry_products&.where(inquiry: row.inward_dispatch&.inquiry)&.last
          dc_row.total_quantity = row&.delivered_quantity
          dc_row.quantity = dc_row.get_quantity
          dc_row.overseer = overseer
        end
      end
    end

    attr_accessor :params, :sales_order, :overseer, :inquiry, :inward_dispatch
end
