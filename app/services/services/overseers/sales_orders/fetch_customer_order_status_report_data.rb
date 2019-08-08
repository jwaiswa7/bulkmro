class Services::Overseers::SalesOrders::FetchCustomerOrderStatusReportData < Services::Shared::BaseService
  def initialize(indexed_sales_orders)
    @indexed_sales_orders = indexed_sales_orders
  end

  def call
    sales_orders = []
    indexed_sales_orders.each do |sales_order|
      if sales_order.attributes['rows'].present?
        sales_order.attributes['rows'].each do |row|
          po_skus = []
          purchase_order_details = {}
          sales_order.attributes['po_requests'].each do |po_request|
            if po_request['purchase_order'].present?
              if po_request['purchase_order']['rows'].present?
                po_request['purchase_order']['rows'].map { |po| po_skus << po['product_id'] }
                if po_skus.include?(row['product_id'])
                  purchase_order_details['supplier_po_request_date'] = po_request['supplier_po_request_date']
                  purchase_order_details['po_number'] = po_request['purchase_order']['po_number']
                  purchase_order_details['supplier_name'] = po_request['purchase_order']['supplier_name']
                  purchase_order_details['supplier_po_date'] = po_request['purchase_order']['supplier_po_date']
                  purchase_order_details['po_email_sent'] = po_request['purchase_order']['po_email_sent']
                  purchase_order_details['payment_date'] = po_request['purchase_order']['payment_date']
                  purchase_order_details['committed_material_readiness_date'] = po_request['purchase_order']['committed_material_readiness_date']
                  purchase_order_details['actual_material_readiness_date'] = po_request['purchase_order']['actual_material_readiness_date']
                  purchase_order_details['pickup_date'] = po_request['purchase_order']['pickup_date']
                  purchase_order_details['inward_date'] = po_request['purchase_order']['inward_date']
                end
              end
            end
          end
          sales_orders << {
              inquiry_number: sales_order.attributes['inquiry_number'],
              company: sales_order.attributes['company'],
              account: sales_order.attributes['account'],
              order_number: sales_order.attributes['order_number'],
              sku: row['sku'],
              mis_date: sales_order.attributes['mis_date'],
              cp_committed_date: sales_order.attributes['cp_committed_date'],

              po_number: purchase_order_details['po_number'].present? ? purchase_order_details['po_number'] : '',
              supplier_name: purchase_order_details['supplier_name'].present? ? purchase_order_details['supplier_name'] : '',
              supplier_po_request_date: purchase_order_details['supplier_po_request_date'].present? ? purchase_order_details['supplier_po_request_date'] : '',
              supplier_po_date: purchase_order_details['supplier_po_date'].present? ? purchase_order_details['supplier_po_date'] : '',
              po_email_sent: purchase_order_details['po_email_sent'].present? ? purchase_order_details['po_email_sent'] : '',
              payment_request_date: purchase_order_details['payment_request_date'].present? ? purchase_order_details['payment_request_date'] : '',
              payment_date: purchase_order_details['payment_date'].present? ? purchase_order_details['payment_date'] : '',
              committed_material_readiness_date: purchase_order_details['committed_material_readiness_date'].present? ? purchase_order_details['committed_material_readiness_date'] : '',
              actual_material_readiness_date: purchase_order_details['actual_material_readiness_date'].present? ? purchase_order_details['actual_material_readiness_date'] : '',
              pickup_date: purchase_order_details['pickup_date'].present? ? purchase_order_details['pickup_date'] : '',
              inward_date: purchase_order_details['inward_date'].present? ? purchase_order_details['inward_date'] : '',

              outward_date: sales_order.attributes['outward_date'].present? ? sales_order.attributes['outward_date'] : '',
              customer_delivery_date: sales_order.attributes['customer_delivery_date'].present? ? sales_order.attributes['customer_delivery_date'] : '',
              on_time_or_delayed_time: sales_order.attributes['on_time_or_delayed_time'].present? ? sales_order.attributes['on_time_or_delayed_time'] : ''
          }
        end
      end
    end

    # indexed_sales_orders.each do |sales_order|
    #   if sales_order.attributes['po_requests'].present?
    #     sales_order.attributes['po_requests'].each do |po_request|
    #       sales_orders << {
    #           inquiry_number: sales_order.attributes['inquiry_number'],
    #           company: sales_order.attributes['company'],
    #           account: sales_order.attributes['account'],
    #           order_number: sales_order.attributes['order_number'],
    #           mis_date: sales_order.attributes['mis_date'],
    #           cp_committed_date: sales_order.attributes['cp_committed_date'],
    #           po_number: po_request['purchase_order'].present? ? po_request['purchase_order']['po_number'] : '',
    #           supplier_name: po_request['purchase_order'].present? ? po_request['purchase_order']['supplier_name'] : '',
    #           supplier_po_request_date: po_request['supplier_po_request_date'],
    #           supplier_po_date: po_request['purchase_order'].present? ? po_request['purchase_order']['supplier_po_date'] : '',
    #           po_email_sent: po_request['purchase_order'].present? && po_request['purchase_order']['po_email_sent'].present? ? po_request['purchase_order']['po_email_sent'] : '',
    #           payment_request_date: po_request['purchase_order'].present? && po_request['purchase_order']['payment_request_date'].present? ? po_request['purchase_order']['payment_request_date'] : '',
    #           payment_date: po_request['purchase_order'].present? && po_request['purchase_order']['payment_date'].present? ? po_request['purchase_order']['payment_date'] : '',
    #           committed_material_readiness_date: po_request['purchase_order'].present? && po_request['purchase_order']['committed_material_readiness_date'].present? ? po_request['purchase_order']['committed_material_readiness_date'] : '',
    #           actual_material_readiness_date: po_request['purchase_order'].present? && po_request['purchase_order']['actual_material_readiness_date'].present? ? po_request['purchase_order']['actual_material_readiness_date'] : '',
    #           pickup_date: po_request['purchase_order'].present? && po_request['purchase_order']['pickup_date'].present? ? po_request['purchase_order']['pickup_date'] : '',
    #           inward_date: po_request['purchase_order'].present? && po_request['purchase_order']['inward_date'].present? ? po_request['purchase_order']['inward_date'] : '',
    #           outward_date: sales_order.attributes['outward_date'].present? ? sales_order.attributes['outward_date'] : '',
    #           customer_delivery_date: sales_order.attributes['customer_delivery_date'].present? ? sales_order.attributes['customer_delivery_date'] : '',
    #           on_time_or_delayed_time: sales_order.attributes['on_time_or_delayed_time'].present? ? sales_order.attributes['on_time_or_delayed_time'] : ''
    #       }
    #     end
    #   else
    #     sales_orders << {
    #         inquiry_number: sales_order.attributes['inquiry_number'],
    #         company: sales_order.attributes['company'],
    #         account: sales_order.attributes['account'],
    #         order_number: sales_order.attributes['order_number'],
    #         mis_date: sales_order.attributes['mis_date'],
    #         cp_committed_date: sales_order.attributes['cp_committed_date'],
    #         po_number: '',
    #         supplier_name: '',
    #         supplier_po_request_date: '',
    #         supplier_po_date: '',
    #         po_email_sent: '',
    #         payment_request_date: '',
    #         payment_date: '',
    #         committed_material_readiness_date: '',
    #         actual_material_readiness_date: '',
    #         pickup_date: '',
    #         inward_date: '',
    #         outward_date: '',
    #         customer_delivery_date: '',
    #         on_time_or_delayed_time: ''
    #     }
    #   end
    # end
    sales_orders
  end

  attr_accessor :indexed_sales_orders
end
