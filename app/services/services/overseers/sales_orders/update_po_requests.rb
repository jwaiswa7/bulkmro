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

      new_po_request = @sales_order.po_requests.new(inquiry_id: @sales_order.inquiry.id, supplier_id: po_request.supplier.id, status: :'Draft')
      po_request_hash[:rows_attributes].each do |index, row_hash|
        if row_hash[:_destroy].present?
          if new_po_request.save!
            PoRequestRow.find(row_hash[:id]).update( po_request: new_po_request)
          end
        elsif row_hash[:quantity].present?
          quantity = PoRequestRow.find(row_hash[:id]).quantity
          if quantity == row_hash[:quantity].to_d
            # PoRequestRow.find(row_hash[:id]).update(status: :'Draft')
          elsif quantity > row_hash[:quantity].to_d
            sales_order_row = PoRequestRow.find(row_hash[:id]).sales_order_row
            PoRequestRow.create!(sales_order_row_id: sales_order_row.id, quantity: row_hash[:quantity],  po_request: po_request)
            if new_po_request.save!
              PoRequestRow.find(row_hash[:id]).update(quantity: (quantity-row_hash[:quantity].to_d), po_request: new_po_request)
            end
          end
        end
      end
      if po_request.status == "Draft"
        not_requested.push po_request
      end
    end
    return not_requested
  end
end