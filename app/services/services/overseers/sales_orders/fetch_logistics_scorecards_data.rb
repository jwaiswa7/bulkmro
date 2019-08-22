class Services::Overseers::SalesOrders::FetchLogisticsScorecardsData < Services::Shared::BaseService
  def initialize(indexed_sales_invoices)
    @indexed_sales_invoices = indexed_sales_invoices
  end

  def call
    sales_invoices = []
    indexed_sales_invoices.each do |sales_invoice|
      if sales_invoice.attributes['rows'].present?
        sales_invoice.attributes['rows'].each do |row|
          sales_invoices << {
              id: sales_invoice.attributes['id'],
              inquiry_number: sales_invoice.attributes['inquiry_number'],
              inquiry_date: sales_invoice.attributes['inquiry_date'],
              company: sales_invoice.attributes['company'],
              inside_sales_owner: sales_invoice.attributes['inside_sales_owner'],
              logistics_owner: sales_invoice.attributes['logistics_owner'].present? ? sales_invoice.attributes['logistics_owner'] : '',
              opportunity_type: sales_invoice.attributes['opportunity_type'],
              sku: row['sku'].present? ? row['sku'] : '',
              sku_description: row['name'].present? ? row['name'] : '',
              item_make: row['brand'].present? ? row['brand'] : '',
              quantity: row['quantity'].present? ? row['quantity'] : '',
              delivery_location: sales_invoice.attributes['so_delivery_location'].present? ? sales_invoice.attributes['so_delivery_location'] : '',
              customer_po_date: sales_invoice.attributes['customer_po_date'].present? ? sales_invoice.attributes['customer_po_date'] : '',
              customer_po_received_date: sales_invoice.attributes['customer_po_received_date'].present? ? sales_invoice.attributes['customer_po_received_date'] : '',
              cp_committed_date: sales_invoice.attributes['cp_committed_date'].present? ? sales_invoice.attributes['cp_committed_date'] : '',
              so_created_at: sales_invoice.attributes['so_created_at'],
              po_created_date: sales_invoice.attributes['supplier_po_created_date'],
              actual_delivery_date: sales_invoice.attributes['actual_delivery_date'].present? ? sales_invoice.attributes['actual_delivery_date'] : '',
              committed_delivery_tat: sales_invoice.attributes['committed_delivery_tat'].present? ? sales_invoice.attributes['committed_delivery_tat'] : '',
              actual_delivery_tat: sales_invoice.attributes['actual_delivery_tat'].present? ? sales_invoice.attributes['actual_delivery_tat'] : '',
              delay: sales_invoice.attributes['delay'].present? ? sales_invoice.attributes['delay'] : '',
              sla_bucket: sales_invoice.attributes['sla_bucket'].present? ? sales_invoice.attributes['sla_bucket'] : '',
              delay_bucket: sales_invoice.attributes['delay_bucket'].present? ? sales_invoice.attributes['delay_bucket'] : '',
              delay_reason: sales_invoice.attributes['delay_reason'].present? ? sales_invoice.attributes['delay_reason'] : '',
              cp_committed_month: sales_invoice.attributes['cp_committed_date'].present? ? sales_invoice.attributes['cp_committed_date'] : ''
          }
        end
      else
        sales_invoices << {
            id: sales_invoice.attributes['id'],
            inquiry_number: sales_invoice.attributes['inquiry_number'],
            inquiry_date: sales_invoice.attributes['inquiry_date'],
            company: sales_invoice.attributes['company'],
            inside_sales_owner: sales_invoice.attributes['inside_sales_owner'],
            logistics_owner: sales_invoice.attributes['logistics_owner'].present? ? sales_invoice.attributes['logistics_owner'] : '',
            opportunity_type: sales_invoice.attributes['opportunity_type'],
            sku: '',
            sku_description: '',
            item_make: '',
            quantity: '',
            delivery_location: '',
            customer_po_date: '',
            customer_po_received_date: '',
            cp_committed_date: '',
            so_created_at: sales_invoice.attributes['so_created_at'],
            po_created_date: '',
            actual_delivery_date: sales_invoice.attributes['actual_delivery_date'].present? ? sales_invoice.attributes['actual_delivery_date'] : '',
            committed_delivery_tat: '',
            actual_delivery_tat: '',
            delay: '',
            sla_bucket: '',
            delay_bucket: '',
            delay_reason: '',
            cp_committed_month: ''
        }
      end
    end
    sales_invoices
  end

  attr_accessor :indexed_sales_invoices
end