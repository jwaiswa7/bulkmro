class Services::Overseers::Reports::InwardLogisticQueue < Services::Overseers::Reports::BaseReport
  def call
    purchase_orders = PurchaseOrder.includes(:inward_dispatches).includes(:po_request)

    @data = OpenStruct.new(
      entries: {}
    )
    with_material_not_ready = PurchaseOrder.where.not(id: PurchaseOrder.joins(:inward_dispatches)).joins(:po_request).where(po_requests: {status: 'Supplier PO Sent'}).group('logistics_owner_id').count

    logistic_overseers = Overseer.where(role: 'logistics')
    @data.entries[:nil] = {name: "Not Assigned" , with_material_not_ready: 0, material_pickups_pending: 0, with_inward_pending: 0, with_status_partial_grpo_done: 0}
    logistic_overseers.each do |logistic_overseer|
      @data.entries[logistic_overseer.id.to_s] = {name: logistic_overseer.to_s, with_material_not_ready: 0, material_pickups_pending: 0, with_inward_pending: 0, with_status_partial_grpo_done: 0}
      if with_material_not_ready.present? && with_material_not_ready.key?(logistic_overseer.id)
        @data.entries[logistic_overseer.id.to_s][:with_material_not_ready] = with_material_not_ready[logistic_overseer.id]
      elsif with_material_not_ready.present? && with_material_not_ready.key?(nil)
        @data.entries[:nil][:with_material_not_ready] = with_material_not_ready[nil]
      end
    end
    data
  end
end
