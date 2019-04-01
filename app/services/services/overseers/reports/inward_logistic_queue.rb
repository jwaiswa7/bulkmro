class Services::Overseers::Reports::InwardLogisticQueue < Services::Overseers::Reports::BaseReport
  def call
    purchase_orders = PurchaseOrder.joins(:inward_dispatches).joins(:po_request)
    @data = OpenStruct.new(
      entries: {}
    )
    with_material_not_ready = PurchaseOrder.where.not(id: PurchaseOrder.joins(:inward_dispatches)).joins(:po_request).where(po_requests: {status: 'Supplier PO Sent'}).group('logistics_owner_id').count
    pickups_pending = purchase_orders.where.not(po_requests: {id: nil}).where(material_status: ['Material Pickedup', 'Material Partially Pickedup', 'Material Partially Delivered']).group(:logistics_owner_id).count
    inward_pending = purchase_orders.where.not(po_requests: {id: nil}).where(material_status: ['Material Delivered', 'Material Partially Delivered']).group(:logistics_owner_id).count
    logistic_overseers = Overseer.where(role: 'logistics').order(:first_name)
    @data.entries[:nil] = {name: 'Not Assigned', with_material_not_ready: 0, material_pickups_pending: 0, with_inward_pending: 0, with_status_partial_grpo_done: 0}
    logistic_overseers.each do |logistic_overseer|
      @data.entries[logistic_overseer.id.to_s] = { name: logistic_overseer.to_s, with_material_not_ready: 0, material_pickups_pending: 0, with_inward_pending: 0, with_status_partial_grpo_done: 0 }
      get_key_value([with_material_not_ready, pickups_pending, inward_pending], ['with_material_not_ready', 'material_pickups_pending', 'with_inward_pending'], logistic_overseer.id)
    end
    data
  end

  def get_key_value(objects, keys, overseer_id)
    objects.each_with_index do |object, index|
      if object.present? && object.key?(overseer_id)
        @data.entries[overseer_id.to_s][keys[index].to_sym] = object[overseer_id]
      elsif object.present? && object.key?(nil)
        @data.entries[:nil][keys[index].to_sym] = object[nil]
      end
    end
  end
end
