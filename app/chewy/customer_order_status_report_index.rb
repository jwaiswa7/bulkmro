class CustomerOrderStatusReportIndex < BaseIndex
  index_scope SalesOrder.where.not(order_number: nil, status: 'Cancelled').with_includes 
    field :id, type: 'integer'
    field :inquiry_id, value: -> (record) { record.inquiry.id if record.inquiry.present? }, type: 'integer'
    field :inquiry_number, value: -> (record) { record.inquiry.inquiry_number.to_i if record.inquiry.present? }, type: 'integer'
    field :inquiry_number_string, value: -> (record) { record.inquiry.inquiry_number.to_s if record.inquiry.present? }, analyzer: 'substring'
    field :inside_sales_owner_id, value: -> (record) { record.inside_sales_owner.id if record.inside_sales_owner.present? }, type: 'integer'
    field :inside_sales_owner, value: -> (record) { record.inquiry&.inside_sales_owner&.to_s }, analyzer: 'substring'
    field :outside_sales_owner_id, value: -> (record) { record.inquiry&.outside_sales_owner&.id if record.inquiry.outside_sales_owner.present? }
    field :outside_sales_owner, value: -> (record) { record.inquiry.outside_sales_owner.to_s }, analyzer: 'substring'
    field :procurement_operations_id, value: -> (record) { record.inquiry.procurement_operations.id if record.inquiry.procurement_operations.present? }
    field :procurement_operations, value: -> (record) { record.inquiry.procurement_operations.to_s }, analyzer: 'substring'
    field :inside_sales_executive, value: -> (record) { record.inquiry.inside_sales_owner_id }
    field :outside_sales_executive, value: -> (record) { record.inquiry.outside_sales_owner_id }
    field :procurement_operations, value: -> (record) { record.inquiry.procurement_operations_id }
    field :company_id, value: -> (record) { record.inquiry.company.id if record.inquiry.present? }, type: 'integer'
    field :company, value: -> (record) { record.inquiry.company.to_s if record.inquiry.present? }, analyzer: 'substring'
    field :account_id, value: -> (record) { record.inquiry.account.id if record.inquiry.present? }, type: 'integer'
    field :account, value: -> (record) { record.inquiry.account.to_s if record.inquiry.present? }, analyzer: 'substring'
    field :order_number, value: -> (record) { record.order_number }, type: 'long'
    field :order_number_string, value: -> (record) { record.order_number.to_s }, analyzer: 'substring'
    field :customer_po_number_string, value: -> (record) { record.inquiry.customer_po_number.to_s if (record.inquiry.present? && record.inquiry.customer_po_number.present?) }, analyzer: 'substring'
    field :created_at, value: -> (record) { record.created_at }, type: 'date'
    field :mis_date, value: -> (record) { record.mis_date if record.mis_date.present? }, type: 'date'
    field :customer_order_date, value: -> (record) { record.inquiry.customer_order_date if record.inquiry.customer_order_date.present? }, type: 'date'
    field :customer_po_delivery_date, value: -> (record) { record.inquiry.customer_po_delivery_date if record.inquiry.customer_po_delivery_date.present? }, type: 'date'
    field :customer_po_received_date, value: -> (record) { record.inquiry.customer_po_received_date if record.inquiry.customer_po_received_date.present? }, type: 'date'
    field :cp_committed_date, value: -> (record) { record.inquiry.customer_committed_date if record.inquiry.customer_committed_date.present? }, type: 'date'
    field :revised_committed_delivery_date, value: -> (record) { record.revised_committed_delivery_date if record.revised_committed_delivery_date.present? }, type: 'date'


    field :outward_date_so_wise, value: -> (record) { record.invoices.last.mis_date if record.invoices.present? && record.invoices.last.status != 'Cancelled' }, type: 'date'
    field :customer_delivery_date_so_wise, value: -> (record) { record.invoices.last.delivery_date if record.invoices.present? }, type: 'date'
    field :delivery_status_so_wise, value: -> (record) { (record.invoices.present? && record.invoices.last.delivery_date.present?) ? (record.invoices.last.delivery_date < Date.today ? 'Delivered' : 'Not Delivered') : 'Not Delivered'}, analyzer: 'substring'
    field :on_time_or_delayed_time_so_wise, value: -> (record) { record.calculate_time_delay }, type: 'integer'

    field :rows, type: 'nested' do
      field :product_id, value: -> (record) { record.get_product.try(:id) }, type: 'integer'
      field :sku, value: -> (record) { record.get_product.try(:sku) }, analyzer: 'sku_substring'
      field :name, value: -> (record) { record.get_product.try(:name) }, analyzer: 'substring'
      field :total_selling_price, value: -> (record) { record.converted_total_selling_price}, type: 'integer'
      field :lead_time, value: -> (record) { record.lead_time}, type: 'date'
    end

    # inquiry purchase orders when po requests not present
    field :inquiry, type: 'nested' do
      field :purchase_orders, type: 'nested' do
        field :po_number, value: -> (record) { record.po_number }, type: 'integer'
        field :po_number_string, value: -> (record) { record.po_number.to_s }, analyzer: 'substring'
        field :supplier_id, value: -> (record) { record.supplier.try(:id) }, type: 'integer'
        field :supplier_name, value: -> (record) { record.supplier.try(:name) }, analyzer: 'substring'
        field :supplier_po_date, value: -> (record) { record.metadata['PoDate'].to_date if record.metadata['PoDate'].present? && record.valid_po_date? }, type: 'date'
        field :po_email_sent, value: -> (record) { record.email_messages.where(email_type: 'Sending PO to Supplier').last.try(:created_at) if record.email_messages.present?  }, type: 'date'
        field :payment_request_date, value: -> (record) { record.payment_request.created_at if record.payment_request.present? }
        field :payment_date, value: -> (record) { record.payment_request.transactions.last.created_at if record.payment_request.present? && record.payment_request.transactions.present? }
        field :supplier_committed_date, value: -> (record) { record.inquiry.customer_committed_date if record.inquiry.customer_committed_date.present? }, type: 'date'
        field :committed_material_readiness_date, value: -> (record) { record.inquiry.customer_committed_date if record.inquiry.customer_committed_date.present? }, type: 'date'
        field :actual_material_readiness_date, value: -> (record) { record.supplier_dispatch_date if record.supplier_dispatch_date.present? }, type: 'date'
        field :pickup_date, value: -> (record) { record.inward_dispatches.last.created_at if record.inward_dispatches.present? }, type: 'date'
        field :inward_date, value: -> (record) { record.inward_dispatches.last.actual_delivery_date if record.inward_dispatches.present? }, type: 'date'
        field :rows do
          field :product_id, value: -> (record) { record.product.try(:id) }, type: 'integer'
          field :sku, value: -> (record) { record.product.try(:sku) }, analyzer: 'sku_substring'
        end
      end
    end

    field :invoices, type: 'nested' do
      field :rows do
        field :on_time_or_delayed_time, value: -> (record) { record.sales_invoice.cosr_calculate_time_delay }, type: 'integer'
        field :invoice_number, value: -> (record) { record.sales_invoice.try(:invoice_number) }, type: 'integer'
        field :invoice_number_string, value: -> (record) { record.sales_invoice.try(:invoice_number).to_s }, analyzer: 'substring'
        field :outward_date, value: -> (record) { record.sales_invoice.try(:mis_date) }, type: 'date'
        field :customer_delivery_date, value: -> (record) { record.sales_invoice.try(:delivery_date) }, type: 'date'
        field :product_id, value: -> (record) { record.get_product_details.try(:id) }, type: 'integer'
        field :sku, value: -> (record) { record.try(:sku) }, analyzer: 'sku_substring'
        field :delivery_status, value: -> (record) { record.sales_invoice.send(:delivery_date).present? ? (record.sales_invoice.send(:delivery_date) < Date.today ? 'Delivered' : 'Not Delivered') : 'Not Delivered'}, analyzer: 'substring'
      end
    end

    field :po_requests, type: 'nested' do
      field :purchase_order do
        field :supplier_po_request_date, value: -> (record) { record.po_request.created_at if record.po_request.present? }, type: 'date'
        field :po_number, value: -> (record) { record.po_number }, type: 'integer'
        field :po_number_string, value: -> (record) { record.po_number.to_s }, analyzer: 'substring'
        field :supplier_id, value: -> (record) { record.supplier.try(:id) }, type: 'integer'
        field :supplier_name, value: -> (record) { record.supplier.try(:name) }, analyzer: 'substring'
        field :supplier_po_date, value: -> (record) { record.metadata['PoDate'].to_date if record.metadata['PoDate'].present? && record.valid_po_date? }, type: 'date'
        field :po_email_sent, value: -> (record) { record.email_messages.where(email_type: 'Sending PO to Supplier').last.try(:created_at) if record.email_messages.present?  }, type: 'date'
        field :payment_request_date, value: -> (record) { record.payment_request.created_at if record.payment_request.present? }
        field :payment_date, value: -> (record) { record.payment_request.transactions.last.created_at if record.payment_request.present? && record.payment_request.transactions.present? }
        field :supplier_committed_date, value: -> (record) { record.inquiry.customer_committed_date if record.inquiry.customer_committed_date.present? }, type: 'date'
        field :committed_material_readiness_date, value: -> (record) { record.inquiry.customer_committed_date if record.inquiry.customer_committed_date.present? }, type: 'date'
        field :actual_material_readiness_date, value: -> (record) { record.supplier_dispatch_date if record.supplier_dispatch_date.present? }, type: 'date'
        field :pickup_date, value: -> (record) { record.inward_dispatches.last.created_at if record.inward_dispatches.present? }, type: 'date'
        field :inward_date, value: -> (record) { record.inward_dispatches.last.actual_delivery_date if record.inward_dispatches.present? }, type: 'date'
        field :rows do
          field :product_id, value: -> (record) { record.product.try(:id) }, type: 'integer'
          field :sku, value: -> (record) { record.product.try(:sku) }, analyzer: 'sku_substring'
          field :lead_time, value: -> (record) {record.po_request_row.try(:lead_time)}, type: 'date'
        end
      end
    end

end
