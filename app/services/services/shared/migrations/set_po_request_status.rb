class Services::Shared::Migrations::SetPoRequestStatus < Services::Shared::Migrations::Migrations
  def call
    PoRequest.where(purchase_order: PurchaseOrder.supplier_email_sent, status: 'Supplier PO: Created Not Sent').update_all(status: 'Supplier PO Sent')
  end

  def migration_of_existing_po
    PurchaseOrder.all.each do |po|
      inward_dispatches = po.inward_dispatches.order(created_at: :desc)
      if inward_dispatches.any?
        invoice_request = inward_dispatches.first.invoice_request
        if invoice_request.present?
          po.update_attribute(:material_status, invoice_request.status)
        else
          partial = true
          if po.rows.sum(&:get_pickup_quantity) <= 0
            partial = false
          end
          if 'Material Pickup'.in? po.inward_dispatches.map(&:status)
            status = partial ? 'Inward Dispatch: Partial' : 'Inward Dispatch'
          elsif 'Material Delivered'.in? po.inward_dispatches.map(&:status)
            status = partial ? 'Material Partially Delivered' : 'Material Delivered'
          end
          po.update_attribute(:material_status, status)
        end
      else
        po.update_attribute(:material_status, 'Material Readiness Follow-Up')
      end
    end
  end
end

