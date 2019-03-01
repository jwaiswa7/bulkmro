class Services::Overseers::SalesOrders::UpdatePoRequests < Services::Shared::BaseService
  def initialize(order, overseer, po_requests, stock_po=false)
    @order = order
    @overseer = overseer
    @po_requests = po_requests
    @stock_po = stock_po
  end

  def call
    @po_requests.each do |index, po_request_hash|
      po_request = PoRequest.new(overseer: @overseer)
      if @order.class.name == 'SalesOrder'
        po_request.sales_order = @order
      elsif @order.class.name == 'Inquiry'
        po_request.inquiry = @order
      end
      if @stock_po
        po_request.po_request_type = 'Stock'
        po_request.stock_status = po_request_hash[:stock_status]
      else
        po_request.po_request_type = 'Supplier'
        po_request.status = po_request_hash[:status]
      end
      po_request.supplier_id = po_request_hash[:supplier_id]
      po_request.inquiry_id = po_request_hash[:inquiry_id]
      po_request.bill_from_id = po_request_hash[:bill_from_id]
      po_request.ship_from_id = po_request_hash[:ship_from_id]
      po_request.bill_to_id = po_request_hash[:bill_to_id]
      po_request.ship_to_id = po_request_hash[:ship_to_id]
      po_request.contact_id = po_request_hash[:contact_id]
      po_request.contact_email = po_request_hash[:contact_email]
      po_request.contact_phone = po_request_hash[:contact_phone]
      po_request.payment_option_id = po_request_hash[:payment_option_id]
      po_request.supplier_po_type = po_request_hash[:supplier_po_type]
      po_request.supplier_committed_date = po_request_hash[:supplier_committed_date]
      po_request.requested_by_id = po_request_hash[:requested_by_id]
      po_request.approved_by_id = po_request_hash[:approved_by_id]
      po_request.reason_to_stock = po_request_hash[:reason_to_stock]
      po_request.estimated_date_to_unstock = po_request_hash[:estimated_date_to_unstock]
      if po_request_hash[:blobs].present?
        po_request_hash[:blobs].split(' ').each do |blob|
          po_request.attachments.attach(ActiveStorage::Blob.find(blob))
        end
      end
      if po_request.save!
        if po_request_hash[:rows_attributes].present?
          po_request_hash[:rows_attributes].each do |row_index, row_hash|
            if !row_hash[:_destroy].present? && row_hash[:quantity].present?
              PoRequestRow.create!(sales_order_row_id: row_hash[:sales_order_row_id], quantity: row_hash[:quantity], po_request: po_request, product_id: row_hash[:product_id], tax_code_id: row_hash[:tax_code_id], tax_rate_id: row_hash[:tax_rate_id], measurement_unit_id: row_hash[:measurement_unit_id], unit_price: row_hash[:unit_price], discount_percentage: row_hash[:discount_percentage], lead_time: row_hash[:lead_time])
            end
          end
        end
        @notification = Services::Overseers::Notifications::Notify.new(@overseer, self.class.parent)
        @notification.send_po_request_creation(
          Services::Overseers::Notifications::Recipients.logistics_owners,
            self.class.name.demodulize,
            po_request,
            Rails.application.routes.url_helpers.overseers_po_request_path(po_request),
            @order.order_number
        ) if po_request.present?
      end
    end
  end
end
