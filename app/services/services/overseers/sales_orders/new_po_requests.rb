class Services::Overseers::SalesOrders::NewPoRequests < Services::Shared::BaseService
  def initialize(sales_order, overseer)
    @sales_order = sales_order
    @overseer = overseer
    @po_requests = {}
  end

  def call
    if !@sales_order.po_requests.present?
      po_requests = {}
      @sales_order.rows.each do |row|


        if po_requests[row.supplier.id] == nil && row.supplier.contacts.any?
          service = Services::Overseers::MaterialPickupRequests::SelectLogisticsOwner.new(nil, company_name: @sales_order.inquiry.company.name)

          po_requests[row.supplier.id] = @sales_order.po_requests.build(inquiry_id: @sales_order.inquiry.id, supplier_id: row.supplier.id, status: :'Requested', bill_from_id: row.supplier.addresses.first.id, ship_from_id: row.supplier.addresses.first.id, bill_to_id: @sales_order.inquiry.bill_from_id, ship_to_id: @sales_order.inquiry.ship_from_id, logistics_owner: service.call)
        end

        po_requests[row.supplier.id].rows.build(sales_order_row_id: row.id, quantity: row.quantity, product_id: row.product.id, brand_id: row.product.try(:brand_id), tax_code: row.tax_code, tax_rate: row.best_tax_rate, measurement_unit: row.measurement_unit, unit_price: row.sales_quote_row.unit_cost_price, lead_time: Date.today) if po_requests[row.supplier.id].present?
      end
    else
      # TODO Look for po_requests where status is created or requested
      # create po_request for remaining product or remainning quantities
      # If po_request Cancelled then find po_requests with same supplier and add product quantities to existing

      po_requests = {}
      @sales_order.rows.each do |row|
        quantity = row.max_po_request_qty

        if quantity > 0
          if !po_requests[row.supplier.id].present? && row.supplier.contacts.any?
            service = Services::Overseers::MaterialPickupRequests::SelectLogisticsOwner.new(nil, company_name: @sales_order.inquiry.company.name)

            po_requests[row.supplier.id] = @sales_order.po_requests.build(inquiry_id: @sales_order.inquiry.id, supplier_id: row.supplier.id, status: :'Requested', bill_from_id: row.supplier.addresses.first.id, ship_from_id: row.supplier.addresses.first.id, bill_to_id: @sales_order.inquiry.bill_from_id, ship_to_id: @sales_order.inquiry.ship_from_id, logistics_owner: service.call)
          end

          po_requests[row.supplier.id].rows.build(sales_order_row_id: row.id, quantity: quantity, product: row.product, brand_id: row.product.try(:brand_id), tax_code: row.tax_code, tax_rate: row.best_tax_rate, measurement_unit: row.measurement_unit, unit_price: row.sales_quote_row.unit_cost_price, lead_time: Date.today) if po_requests[row.supplier.id].present?
        end
      end
    end
    po_requests
  end

  attr_accessor :po_requests
end