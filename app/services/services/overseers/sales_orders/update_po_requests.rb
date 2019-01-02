class Services::Overseers::SalesOrders::UpdatePoRequests < Services::Shared::BaseService
  def initialize(sales_order, overseer, po_requests)
    @sales_order = sales_order
    @overseer = overseer
    @po_requests = po_requests
  end

  def call
    not_requested = []
    @po_requests.each do |index, po_request_hash|
      po_request = PoRequest.find(po_request_hash[:id])
      po_request.status = po_request_hash[:status]
      po_request.logistics_owner_id = po_request_hash[:logistics_owner_id]
      po_request.address_id = po_request_hash[:address_id]
      po_request.contact_id = po_request_hash[:contact_id]
      po_request.attachments = po_request_hash[:attachments] if po_request_hash[:attachments].present?
      po_request.save!
      po_request_hash[:rows_attributes].each do |index, row_hash|
        if row_hash[:_destroy].present?
          PoRequestRow.find(row_hash[:id]).destroy
        end
      end
      if po_request.status == "Draft"
        not_requested.push po_request
      end
    end
    return not_requested
  end
end