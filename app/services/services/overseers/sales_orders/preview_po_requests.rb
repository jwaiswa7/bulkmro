class Services::Overseers::SalesOrders::PreviewPoRequests < Services::Shared::BaseService
  def initialize(sales_order, overseer, params)
    @sales_order = sales_order
    @overseer = overseer
    @params = params
    @po_requests = {}
  end

  def call
      po_requests = {}
      @params.each do |index, po_request_hash|
        attachments = po_request_hash[:attachments] if po_request_hash[:attachments].present?
        po_requests[po_request_hash[:supplier_id]] = @sales_order.po_requests.build(inquiry_id: @sales_order.inquiry.id, logistics_owner_id: po_request_hash[:logistics_owner_id], supplier_id: po_request_hash[:supplier_id], status: po_request_hash[:status], address_id: po_request_hash[:address_id], contact_id: po_request_hash[:contact_id], supplier_committed_date: po_request_hash[:supplier_committed_date], payment_option_id: po_request_hash[:payment_option_id], attachments: attachments)
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
                po_requests[po_request_hash[:supplier_id]].rows.build(sales_order_row_id: row_hash[:sales_order_row_id], quantity: row_hash[:quantity], product_id: row_hash[:product_id], tax_code_id: row_hash[:tax_code_id], tax_rate_id: row_hash[:tax_rate_id], measurement_unit_id: measurement_unit_id, unit_price: row_hash[:unit_price], discount_percentage: row_hash[:discount_percentage])
              end
            end
          end
        end
    po_requests
  end

  attr_accessor :po_requests
end