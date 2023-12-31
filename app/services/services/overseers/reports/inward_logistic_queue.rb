class Services::Overseers::Reports::InwardLogisticQueue < Services::Overseers::Reports::BaseReport
  def call
    purchase_orders = PurchaseOrder.joins(:inward_dispatches).joins(:po_request)
    @data = OpenStruct.new(
      entries: {},
      summary_box_data: { with_material_not_ready: 0, material_pickups_pending: 0, with_inward_pending: 0, with_status_partial_grpo_done: 0 }
    )
    with_material_not_ready = PurchaseOrder.where.not(id: PurchaseOrder.joins(:inward_dispatches)).joins(:po_request).where(po_requests: {status: 'Supplier PO Sent'}).group('logistics_owner_id').count
    pickups_pending = purchase_orders.where.not(po_requests: {id: nil}).where(material_status: ['Inward Dispatch', 'Inward Dispatch: Partial', 'Material Partially Delivered']).group(:logistics_owner_id).count
    inward_pending = purchase_orders.where.not(po_requests: {id: nil}).where(material_status: ['Material Delivered', 'Material Partially Delivered']).group(:logistics_owner_id).count
    partial_purchase_order_with_grpo = PurchaseOrder.where(is_partial: true, status: 40)

    @data.summary_box_data[:with_material_not_ready] = with_material_not_ready.values.sum
    @data.summary_box_data[:material_pickups_pending] = pickups_pending.values.sum
    @data.summary_box_data[:with_inward_pending] = inward_pending.values.sum
    if partial_purchase_order_with_grpo.present?
      partial_purchase_order_with_logistics = partial_purchase_order_with_grpo.group(:logistics_owner_id).count
    end
    logistic_overseers = Overseer.where(role: 'logistics').order(:first_name)
    @data.entries[:nil] = { name: 'Not Assigned', with_material_not_ready: 0, material_pickups_pending: 0, with_inward_pending: 0, with_status_partial_grpo_done: 0 }

    logistic_overseers.each do |logistic_overseer|
      @data.entries[logistic_overseer.id.to_s] = { name: logistic_overseer.to_s, with_material_not_ready: 0, material_pickups_pending: 0, with_inward_pending: 0, with_status_partial_grpo_done: 0 }
      get_key_value([with_material_not_ready, pickups_pending, inward_pending, partial_purchase_order_with_logistics], ['with_material_not_ready', 'material_pickups_pending', 'with_inward_pending', 'with_status_partial_grpo_done'], logistic_overseer.id)
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
