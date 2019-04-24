class Services::Shared::Migrations::OutwardQueMigration < Services::Shared::Migrations::Migrations
  def addAssociationInInwardDisapatch
    not_done = []
    InwardDispatch.all.each do |inward_dispatch|
      purchase_order = inward_dispatch.purchase_order
      sales_order = purchase_order.try(:po_request).try(:sales_order)
      if sales_order.present?
        inward_dispatch.sales_order_id = sales_order.id
        if inward_dispatch.valid?
          inward_dispatch.save
        else
          not_done << inward_dispatch.id
        end
      end
    end
    p '******************************'
    binding.pry
    p not_done
  end

end

