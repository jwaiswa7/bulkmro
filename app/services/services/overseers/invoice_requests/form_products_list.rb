class Services::Overseers::InvoiceRequests::FormProductsList < Services::Shared::BaseService
  def initialize(object, by_po)
    @object = object
    @by_po = by_po
  end

  def call
    if by_po == true
      object.rows.map { |row| { purchase_order_row: row, total_quantity: row.metadata['PopQty'] } }
    else
      InwardDispatchRow.where(inward_dispatch_id: object)
            .group_by(&:purchase_order_row_id)
          .map { |por_id, inward_dispatch_rows| { purchase_order_row: PurchaseOrderRow.find(por_id), total_quantity: inward_dispatch_rows.sum(&:delivered_quantity).to_s } }
    end
  end

  private
    attr_accessor :object, :by_po
end
