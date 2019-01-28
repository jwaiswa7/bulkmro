class Services::Overseers::SalesOrders:: UpdatePoRequests < Services::Shared::BaseService
  def initialize(sales_order, overseer, po_requests)
    @sales_order = sales_order
    @overseer = overseer
    @po_requests = po_requests
  end

  def call
    @po_requests.each do |index, po_request_hash|
      po_request = PoRequest.new
      po_request.sales_order = @sales_order
      po_request.status = po_request_hash[:status]
      po_request.logistics_owner_id = po_request_hash[:logistics_owner_id]
      po_request.supplier_id = po_request_hash[:supplier_id]
      po_request.inquiry_id = po_request_hash[:inquiry_id]
      po_request.address_id = po_request_hash[:address_id]
      po_request.contact_id = po_request_hash[:contact_id]
      po_request.payment_option_id = po_request_hash[:payment_option_id]
      po_request.supplier_committed_date = po_request_hash[:supplier_committed_date]
      if po_request_hash[:blobs].present?
        po_request_hash[:blobs].split(" ").each do | blob |
          po_request.attachments.attach(ActiveStorage::Blob.find(blob))
        end
      end
      if(po_request.save)
        if po_request_hash[:rows_attributes].present?
          po_request_hash[:rows_attributes].each do |index, row_hash|
            if !row_hash[:_destroy].present? && row_hash[:quantity].present?
              PoRequestRow.create!(sales_order_row_id: row_hash[:sales_order_row_id], quantity: row_hash[:quantity],  po_request: po_request, product_id: row_hash[:product_id], tax_code_id: row_hash[:tax_code_id], tax_rate_id: row_hash[:tax_rate_id], measurement_unit_id: row_hash[:measurement_unit_id])
            end
          end
        end
      end
    end
  end
end