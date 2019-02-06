class Services::Overseers::SalesOrders::PreviewPoRequests < Services::Shared::BaseService
  def initialize(order, overseer, params)
    @order = order
    @overseer = overseer
    @params = params
    @po_requests = {}
  end

  def call
    po_requests = {}
    @params.each do |index, po_request_hash|
      attachments = po_request_hash[:attachments] if po_request_hash[:attachments].present?
      contact_email = ''; contact_phone = ''
      if po_request_hash[:contact_id].present?
        contact_email = po_request_hash[:contact_email].present? ? po_request_hash[:contact_email] : Contact.find(po_request_hash[:contact_id]).email
        contact_phone = po_request_hash[:contact_phone].present? ? po_request_hash[:contact_phone] : Contact.find(po_request_hash[:contact_id]).phone
      end
      if @order.class.name == 'SalesOrder'
        po_requests[po_request_hash[:supplier_id]] = @order.po_requests.build(inquiry_id: @order.inquiry.id, logistics_owner_id: po_request_hash[:logistics_owner_id], supplier_id: po_request_hash[:supplier_id], status: po_request_hash[:status], supplier_po_type: po_request_hash[:supplier_po_type], bill_from_id: po_request_hash[:bill_from_id], ship_from_id: po_request_hash[:ship_from_id], bill_to_id: po_request_hash[:bill_to_id], ship_to_id: po_request_hash[:ship_to_id], contact_id: po_request_hash[:contact_id], contact_phone: contact_phone, contact_email: contact_email, supplier_committed_date: po_request_hash[:supplier_committed_date], payment_option_id: po_request_hash[:payment_option_id], attachments: attachments)
      elsif @order.class.name == 'Inquiry'
        po_requests[po_request_hash[:supplier_id]] = @order.po_requests.build(inquiry_id: @order.id, logistics_owner_id: po_request_hash[:logistics_owner_id], supplier_id: po_request_hash[:supplier_id], stock_status: po_request_hash[:stock_status], supplier_po_type: po_request_hash[:supplier_po_type], bill_from_id: po_request_hash[:bill_from_id], ship_from_id: po_request_hash[:ship_from_id], bill_to_id: po_request_hash[:bill_to_id], ship_to_id: po_request_hash[:ship_to_id], contact_id: po_request_hash[:contact_id], contact_phone: contact_phone, contact_email: contact_email, supplier_committed_date: po_request_hash[:supplier_committed_date], payment_option_id: po_request_hash[:payment_option_id], requested_by_id: po_request_hash[:requested_by_id], approved_by_id: po_request_hash[:approved_by_id], reason_to_stock: po_request_hash[:reason_to_stock], estimated_date_to_unstock: po_request_hash[:estimated_date_to_unstock], attachments: attachments)
      end
      blobs = Array.new
      if po_requests[po_request_hash[:supplier_id]].attachments.present?
        po_requests[po_request_hash[:supplier_id]].attachments.each do |attachment|
          blobs << attachment.blob_id
        end
      end
      po_requests[po_request_hash[:supplier_id]].blobs = blobs
      if po_request_hash[:rows_attributes].present?
        po_request_hash[:rows_attributes].each do |index, row_hash|
          if !row_hash[:_destroy].present? && row_hash[:quantity].present?
            if row_hash[:measurement_unit_id].present?
              measurement_unit_id = row_hash[:measurement_unit_id]
            else
              measurement_unit_id = Product.find(row_hash[:product_id]).try(:measurement_unit).id
            end
            po_requests[po_request_hash[:supplier_id]].rows.build(sales_order_row_id: row_hash[:sales_order_row_id], quantity: row_hash[:quantity], product_id: row_hash[:product_id], tax_code_id: row_hash[:tax_code_id], tax_rate_id: row_hash[:tax_rate_id], measurement_unit_id: measurement_unit_id, unit_price: row_hash[:unit_price], discount_percentage: row_hash[:discount_percentage], lead_time: row_hash[:lead_time])
          end
        end
      end
    end
    po_requests
  end

  attr_accessor :po_requests
end