class Services::Shared::Migrations::OutwardQueMigration < Services::Shared::Migrations::Migrations
  def addAssociationInInwardDisapatch
    InwardDispatch.all.each do |inward_dispatch|
      purchase_order = inward_dispatch.purchase_order
      sales_order = purchase_order.try(:po_request).try(:sales_order)
      if sales_order.present?
        inward_dispatch.sales_order = sales_order
        inward_dispatch.save(validate: false)
      end
    end
  end

end

