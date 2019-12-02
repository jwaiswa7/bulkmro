class Services::Overseers::SalesOrders::FetchCustomerOrderStatusReportData < Services::Shared::BaseService
  def initialize(indexed_sales_orders, delivery_status)
    @indexed_sales_orders = indexed_sales_orders
    @delivery_status = delivery_status
  end

  def fetch_data_bm_wise
    sales_orders = []
    indexed_sales_orders.each do |sales_order|
      so_primary_details = {
          id: sales_order.attributes['id'],
          inquiry_number: sales_order.attributes['inquiry_number'],
          company: sales_order.attributes['company'],
          account: sales_order.attributes['account'],
          order_number: sales_order.attributes['order_number'],
          mis_date: sales_order.attributes['mis_date'],
          cp_committed_date: sales_order.attributes['cp_committed_date']
      }
      if sales_order.attributes['rows'].present?
        so_rows = sales_order.attributes['rows']
        so_invoices = sales_order.attributes['invoices'] if sales_order.attributes['invoices'].present?
        so_inquiry_purchase_orders = sales_order.attributes['inquiry']['purchase_orders'] if sales_order.attributes['inquiry']['purchase_orders'].present?
        so_po_requests = sales_order.attributes['po_requests'] if sales_order.attributes['po_requests'].present?
        so_purchase_orders = so_po_requests.map { |po_request| po_request['purchase_order'] } if so_po_requests.present?
        invoice_skus = so_invoices.map { |si| si['rows'].map { |row| row['sku'] } if si['rows'].present? }.compact.uniq.flatten if so_invoices.present?
        po_skus = so_purchase_orders.map { |po| po['rows'].pluck('sku') if po.present? }.compact.flatten if so_purchase_orders.present?
        inquiry_po_skus = so_inquiry_purchase_orders.map { |po| po['rows'].pluck('sku') if po.present? }.compact.flatten if so_inquiry_purchase_orders.present?

        so_rows.each do |so_row|
          purchase_order_details = {}
          # if invoices present of sales order
          if so_invoices.present?
            so_invoices.each do |so_invoice|
              if so_invoice['rows'].present?
                so_invoice['rows'].each do |invoice_row|
                  if (invoice_row['sku'] == so_row['sku']) && so_purchase_orders.present?
                    so_purchase_orders.each do |so_purchase_order|
                      if so_purchase_order.present? && so_purchase_order['rows'].present?
                        so_purchase_order['rows'].each do |po_row|
                          if po_row['sku'] == invoice_row['sku']
                            purchase_order_details = get_purchase_order_details(po_row['sku'], so_purchase_order)
                            sales_orders << get_sales_order_details(so_primary_details, so_row, invoice_row, purchase_order_details)
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
            #   if invoices present but sku is not present in sales invoice but present in purchase_orders
          elsif so_purchase_orders.present? && (so_invoices.present? && invoice_skus.exclude?(so_row['sku']))
            so_purchase_orders.each do |so_purchase_order|
              if so_purchase_order.present? && so_purchase_order['rows'].present?
                so_purchase_order['rows'].each do |po_row|
                  if invoice_skus.exclude?(po_row['sku'])
                    purchase_order_details = get_purchase_order_details(po_row['sku'], so_purchase_order)
                    sales_orders << get_sales_order_details(so_primary_details, so_row, nil, purchase_order_details)
                  end
                end
              end
            end
          end
          #  if invoices not present and po requests and purchase orders present
          if so_purchase_orders.present? && !so_invoices.present?
            so_purchase_orders.each do |so_purchase_order|
              if so_purchase_order.present? && so_purchase_order['rows'].present?
                so_purchase_order['rows'].each do |po_row|
                  if po_row['sku'] == so_row['sku']
                    purchase_order_details = get_purchase_order_details(po_row['sku'], so_purchase_order)
                    sales_orders << get_sales_order_details(so_primary_details, so_row, nil, purchase_order_details)
                  end
                end
              end
            end
            #   if po requests and purchase orders present but sku is not present in purchase order but present in sales order
          elsif po_skus.present? && po_skus.exclude?(so_row['sku'])
            sales_orders << get_sales_order_details(so_primary_details, so_row, nil, nil)
          end

          # if po requests are not present but purchase orders are present of sales orders
          if so_inquiry_purchase_orders.present? && !so_purchase_orders.present? && !so_invoices.present?
            so_inquiry_purchase_orders.each do |so_purchase_order|
              if so_purchase_order.present? && so_purchase_order['rows'].present?
                so_purchase_order['rows'].each do |po_row|
                  if po_row['sku'] == so_row['sku']
                    purchase_order_details = get_purchase_order_details(po_row['sku'], so_purchase_order)
                    sales_orders << get_sales_order_details(so_primary_details, so_row, nil, purchase_order_details)
                  end
                end
              end
            end
            #   purchase orders present but sku is not present in purchase order but present in sales order
          elsif inquiry_po_skus.present? && inquiry_po_skus.exclude?(so_row['sku'])
            sales_orders << get_sales_order_details(so_primary_details, so_row, nil, nil)
          end
          # if invoices or purchase_orders with po request or purchase_orders without po request are not present
          if !so_invoices.present? && !so_purchase_orders.present? && !so_inquiry_purchase_orders
            sales_orders << get_sales_order_details(so_primary_details, so_row, nil, nil)
          end
        end
      end
    end
    sales_orders
  end

  def fetch_data_sales_order_wise
    sales_orders = []
    indexed_sales_orders.each do |sales_order|
      so_primary_details = {
          id: sales_order.attributes['id'],
          inquiry_number: sales_order.attributes['inquiry_number'],
          company: sales_order.attributes['company'],
          account: sales_order.attributes['account'],
          order_number: sales_order.attributes['order_number'],
          mis_date: sales_order.attributes['mis_date'],
          cp_committed_date: sales_order.attributes['cp_committed_date']
      }
      invoice_details = {
          outward_date: sales_order.attributes['outward_date_so_wise'],
          customer_delivery_date: sales_order.attributes['customer_delivery_date'],
          on_time_or_delayed_time: sales_order.attributes['on_time_or_delayed_time_so_wise'],
          delivery_status: sales_order.attributes['delivery_status_so_wise'],
      }

      if sales_order.attributes['rows'].present?
        so_rows = sales_order.attributes['rows']
        so_inquiry_purchase_orders = sales_order.attributes['inquiry']['purchase_orders'] if sales_order.attributes['inquiry']['purchase_orders'].present?
        so_po_requests = sales_order.attributes['po_requests'] if sales_order.attributes['po_requests'].present?
        so_purchase_orders = so_po_requests.map { |po_request| po_request['purchase_order'] } if so_po_requests.present?


        so_rows.each do |so_row|
          purchase_order_details = {}
          if so_purchase_orders.present?
            so_purchase_orders.each do |so_purchase_order|
              if so_purchase_order.present?
                purchase_order_details = get_purchase_order_details(nil, so_purchase_order)
                sales_orders << get_sales_order_details(so_primary_details, so_row, invoice_details, purchase_order_details)
              end
            end
            #   if po requests and purchase orders present but sku is not present in purchase order but present in sales order
          end

          # if po requests are not present but purchase orders are present of sales orders
          if so_inquiry_purchase_orders.present? && !so_purchase_orders.present?
            so_inquiry_purchase_orders.each do |so_purchase_order|
              if so_purchase_order.present?
                purchase_order_details = get_purchase_order_details(nil, so_purchase_order)
                sales_orders << get_sales_order_details(so_primary_details, so_row, invoice_details, purchase_order_details)
              end
            end
          end
          # if invoices or purchase_orders with po request or purchase_orders without po request are not present
          if !so_purchase_orders.present? && !so_inquiry_purchase_orders
            sales_orders << get_sales_order_details(so_primary_details, so_row, invoice_details, nil)
          end
        end
      end
    end
    sales_orders
  end

  def get_purchase_order_details(sku, so_purchase_order)
    po_details = {}
    po_details = {
        'sku': sku,
        'supplier_po_request_date': so_purchase_order['supplier_po_request_date'],
        'po_number': so_purchase_order['po_number'],
        'supplier_id': so_purchase_order['supplier_id'],
        'supplier_name': so_purchase_order['supplier_name'],
        'supplier_po_date': so_purchase_order['supplier_po_date'],
        'po_email_sent': so_purchase_order['po_email_sent'],
        'payment_date': so_purchase_order['payment_date'],
        'committed_material_readiness_date': so_purchase_order['committed_material_readiness_date'],
        'actual_material_readiness_date': so_purchase_order['actual_material_readiness_date'],
        'pickup_date': so_purchase_order['pickup_date'],
        'inward_date': so_purchase_order['inward_date'],
        'lead_time': so_purchase_order['rows'].select { |row| row['sku'] == sku  }.first['lead_time']
    }
    po_details

  end

  def get_sales_order_details(so_details, so_row, invoice_details = nil, purchase_order_details = nil)
    {
        id: so_details[:id],
        inquiry_number: so_details[:inquiry_number],
        company: so_details[:company],
        account: so_details[:account],
        order_number: so_details[:order_number],
        invoice_number: invoice_details.present? && invoice_details['invoice_number'].present? ? invoice_details['invoice_number'] : '',
        sku: so_row['sku'].present? ? so_row['sku'] : '',
        mis_date: so_details[:mis_date],
        cp_committed_date: so_details[:cp_committed_date],
        po_number: purchase_order_details.present? && purchase_order_details[:po_number].present? ? purchase_order_details[:po_number] : '',
        supplier_id: purchase_order_details.present? && purchase_order_details[:supplier_id].present? ? purchase_order_details[:supplier_id] : '',
        supplier_name: purchase_order_details.present? && purchase_order_details[:supplier_name].present? ? purchase_order_details[:supplier_name] : '',
        supplier_po_request_date: purchase_order_details.present? && purchase_order_details[:supplier_po_request_date].present? ? purchase_order_details[:supplier_po_request_date] : '',
        supplier_po_date: purchase_order_details.present? && purchase_order_details[:supplier_po_date].present? ? purchase_order_details[:supplier_po_date] : '',
        po_email_sent: purchase_order_details.present? && purchase_order_details[:po_email_sent].present? ? purchase_order_details[:po_email_sent] : '',
        payment_request_date: purchase_order_details.present? && purchase_order_details[:payment_request_date].present? ? purchase_order_details[:payment_request_date] : '',
        payment_date: purchase_order_details.present? && purchase_order_details[:payment_date].present? ? purchase_order_details[:payment_date] : '',
        committed_material_readiness_date: purchase_order_details.present? && purchase_order_details[:committed_material_readiness_date].present? ? purchase_order_details[:committed_material_readiness_date] : '',
        actual_material_readiness_date: purchase_order_details.present? && purchase_order_details[:actual_material_readiness_date].present? ? purchase_order_details[:actual_material_readiness_date] : '',
        pickup_date: purchase_order_details.present? && purchase_order_details[:pickup_date].present? ? purchase_order_details[:pickup_date] : '',
        inward_date: purchase_order_details.present? && purchase_order_details[:inward_date].present? ? purchase_order_details[:inward_date] : '',
        lead_time: purchase_order_details.present? && purchase_order_details[:lead_time].present? ? purchase_order_details[:lead_time] : '',
        outward_date: invoice_details.present? && invoice_details['outward_date'].present? ? invoice_details['outward_date'] : '',
        customer_delivery_date: invoice_details.present? && invoice_details['customer_delivery_date'].present? ? invoice_details['customer_delivery_date'] : '',
        delivery_status: invoice_details.present? && invoice_details['delivery_status'].present? ? invoice_details['delivery_status'] : 'Not Delivered',
        on_time_or_delayed_time: invoice_details.present? && invoice_details['on_time_or_delayed_time'].present? ? invoice_details['on_time_or_delayed_time'] : ''
    }
  end

  attr_accessor :indexed_sales_orders, :delivery_status
end
