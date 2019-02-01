class Services::Overseers::InvoiceRequests::FormProductsList < Services::Shared::BaseService
  def initialize(mpr_ids)
    @mpr_ids = mpr_ids
  end

  def call
    MprRow.where(material_pickup_request_id: mpr_ids)
          .group_by(&:purchase_order_row_id)
          .map{|por_id, mpr_rows| {purchase_order_row: PurchaseOrderRow.find(por_id), total_quantity: mpr_rows.sum(&:delivered_quantity).to_s}}
  end

  private
  attr_accessor :mpr_ids
end