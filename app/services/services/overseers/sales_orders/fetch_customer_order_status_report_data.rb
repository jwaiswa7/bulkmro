class Services::Overseers::SalesOrders::FetchCustomerOrderStatusReportData < Services::Shared::BaseService
  def initialize(indexed_sales_orders)
    @indexed_sales_orders = indexed_sales_orders
  end

  def call
    sales_orders = []
    indexed_sales_orders.each do |sales_order|
      if sales_order.attributes['po_requests'].present?
        sales_order.attributes['po_requests'].each do |po_request|
          sales_orders << {
              inquiry_number: sales_order.attributes['inquiry_number'],
              company: sales_order.attributes['company'],
              order_number: sales_order.attributes['order_number'],
              mis_date: sales_order.attributes['mis_date'],
              cp_committed_date: sales_order.attributes['cp_committed_date'],
              po_number: po_request['purchase_order'].present? ? po_request['purchase_order']['po_number'] : '',
              supplier_name: po_request['purchase_order'].present? ? po_request['purchase_order']['supplier_name'] : '',
              supplier_po_request_date: po_request['supplier_po_request_date'],
              supplier_po_date: po_request['purchase_order'].present? ? po_request['purchase_order']['supplier_po_date'] : '',
              po_email_sent: po_request['purchase_order'].present? && po_request['purchase_order']['po_email_sent'].present? ? po_request['purchase_order']['po_email_sent'] : '',
              payment_request_date: po_request['purchase_order'].present? && po_request['purchase_order']['payment_request_date'].present? ? po_request['purchase_order']['payment_request_date'] : '',
              payment_date: po_request['purchase_order'].present? && po_request['purchase_order']['payment_date'].present? ? po_request['purchase_order']['payment_date'] : '',
              committed_material_readiness_date: po_request['purchase_order'].present? && po_request['purchase_order']['committed_material_readiness_date'].present? ? po_request['purchase_order']['committed_material_readiness_date'] : '',
              actual_material_readiness_date: po_request['purchase_order'].present? && po_request['purchase_order']['actual_material_readiness_date'].present? ? po_request['purchase_order']['actual_material_readiness_date'] : '',
              pickup_date: po_request['purchase_order'].present? && po_request['purchase_order']['pickup_date'].present? ? po_request['purchase_order']['pickup_date'] : '',
              inward_date: po_request['purchase_order'].present? && po_request['purchase_order']['inward_date'].present? ? po_request['purchase_order']['inward_date'] : '',
              outward_date: sales_order.attributes['outward_date'].present? ? sales_order.attributes['outward_date'] : '',
              customer_delivery_date: sales_order.attributes['customer_delivery_date'].present? ? sales_order.attributes['customer_delivery_date'] : '',
              on_time_or_delayed_time: sales_order.attributes['on_time_or_delayed_time'].present? ? sales_order.attributes['on_time_or_delayed_time'] : ''
          }
        end
      else
        sales_orders << {
            inquiry_number: sales_order.attributes['inquiry_number'],
            company: sales_order.attributes['company'],
            order_number: sales_order.attributes['order_number'],
            mis_date: sales_order.attributes['mis_date'],
            cp_committed_date: sales_order.attributes['cp_committed_date'],
            po_number: '',
            supplier_name: '',
            supplier_po_request_date: '',
            supplier_po_date: '',
            po_email_sent: '',
            payment_request_date: '',
            payment_date: '',
            committed_material_readiness_date: '',
            actual_material_readiness_date: '',
            pickup_date: '',
            inward_date: '',
            outward_date: '',
            customer_delivery_date: '',
            on_time_or_delayed_time: ''
        }
      end
    end
    sales_orders
  end

  attr_accessor :indexed_sales_orders
end
