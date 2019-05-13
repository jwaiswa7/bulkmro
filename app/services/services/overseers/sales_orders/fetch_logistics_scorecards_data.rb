class Services::Overseers::SalesOrders::FetchLogisticsScorecardsData < Services::Shared::BaseService
  def initialize(indexed_sales_orders)
    @indexed_sales_orders = indexed_sales_orders
  end

  def call
    sales_orders = []
    indexed_sales_orders.each do |sales_order|
      if sales_order.attributes['rows'].present?
        sales_order.attributes['rows'].each do |row|
          sales_orders << {
              inquiry_number: sales_order.attributes['inquiry_number'],
              inquiry_date: sales_order.attributes['inquiry_date'],
              company: sales_order.attributes['company'],
              inside_sales_owner: sales_order.attributes['inside_sales_owner'],
              logistics_owner: sales_order.attributes['logistics_owner'],
              opportunity_type: sales_order.attributes['opportunity_type'],
              sku: row.attributes['sku'],
              sku_description: row.attributes['name'],
              item_make: row.attributes['brand'],
              quantity: row.attributes['quantity'],
              delivery_location: sales_order.attributes['so_delivery_location'],
              customer_po_date: sales_order.attributes['customer_po_date'],
              customer_po_received_date: sales_order.attributes['customer_po_received_date'],
              cp_committed_date: sales_order.attributes['cp_committed_date'],
              so_created_at: sales_order.attributes['created_at']
          }
        end
      else
        sales_orders << {
            inquiry_number: sales_order.attributes['inquiry_number'],
            inquiry_date: sales_order.attributes['inquiry_date'],
            company: sales_order.attributes['company'],
            inside_sales_owner: sales_order.attributes['inside_sales_owner'],
            logistics_owner: sales_order.attributes['logistics_owner'],
            opportunity_type: sales_order.attributes['opportunity_type'],
            sku: '-',
            sku_description: '-',
            item_make: '-',
            quantity: '-',
            delivery_location: sales_order.attributes['so_delivery_location'],
            customer_po_date: sales_order.attributes['customer_po_date'],
            customer_po_received_date: sales_order.attributes['customer_po_received_date'],
            cp_committed_date: sales_order.attributes['cp_committed_date'],
            so_created_at: sales_order.attributes['created_at']
        }
      end
    end
    sales_orders
  end


  def call1
    sales_orders = []
    indexed_sales_orders.each do |sales_order|
      if sales_order.attributes['rows'].present?
        sales_order.attributes


        sales_order.attributes['rows'].each do |row|
          sales_orders << {
              inquiry_number: sales_order.attributes['inquiry_number'],
              inquiry_date: sales_order.attributes['inquiry_date'],
              company: sales_order.attributes['company'],
              inside_sales_owner: sales_order.attributes['inside_sales_owner'],
              logistics_owner: sales_order.attributes['logistics_owner'],
              opportunity_type: sales_order.attributes['opportunity_type'],
              sku: row.attributes['sku'],
              sku_description: row.attributes['name'],
              item_make: row.attributes['brand'],
              quantity: row.attributes['quantity'],
              delivery_location: sales_order.attributes['so_delivery_location'],
              customer_po_date: sales_order.attributes['customer_po_date'],
              customer_po_received_date: sales_order.attributes['customer_po_received_date'],
              cp_committed_date: sales_order.attributes['cp_committed_date'],
              so_created_at: sales_order.attributes['created_at']
          }
        end
      else
        sales_orders << {
            inquiry_number: sales_order.attributes['inquiry_number'],
            inquiry_date: sales_order.attributes['inquiry_date'],
            company: sales_order.attributes['company'],
            inside_sales_owner: sales_order.attributes['inside_sales_owner'],
            logistics_owner: sales_order.attributes['logistics_owner'],
            opportunity_type: sales_order.attributes['opportunity_type'],
            sku: '-',
            sku_description: '-',
            item_make: '-',
            quantity: '-',
            delivery_location: sales_order.attributes['so_delivery_location'],
            customer_po_date: sales_order.attributes['customer_po_date'],
            customer_po_received_date: sales_order.attributes['customer_po_received_date'],
            cp_committed_date: sales_order.attributes['cp_committed_date'],
            so_created_at: sales_order.attributes['created_at']
        }
      end
    end
    sales_orders
  end

  private

  # def calculate_delivery_date(sku, invoices)
  #   if invoices.present?
  #     invoices.each do |row|
  #
  #     end
  #   end
  # end

  attr_accessor :indexed_sales_orders
end