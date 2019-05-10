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


  def createArInvoiceAndRows
    status = []
    InvoiceRequest.all.each do |invoice_request|
      if invoice_request.status == 'Completed AR Invoice Request'
        ar_invoice_request = ArInvoiceRequest.where(ar_invoice_number: invoice_request.ar_invoice_number).last
        if !ar_invoice_request.present?
          Chewy.strategy(:bypass) do
            if invoice_request.inward_dispatches.present?
              inward_dispatch = invoice_request.inward_dispatches.last
              inward_dispatch_rows = inward_dispatch.rows
              if inward_dispatch.sales_order.present?
                ar_invoice_request = ArInvoiceRequest.new(overseer: invoice_request.created_by, sales_order: inward_dispatch.sales_order, inquiry: inward_dispatch.inquiry, status: 'Completed AR Invoice Request', ar_invoice_number: invoice_request.ar_invoice_number)
                sales_order_rows = inward_dispatch.sales_order.rows.order(:created_at)
                sales_order_row_ids = sales_order_rows.pluck(:id)
                product_ids = sales_order_rows.map{ |x| x.product.id}
                inward_dispatch_rows.each do |row|
                  index = product_ids.index(row.purchase_order_row.product_id)
                  if index
                    sales_order_row_id = sales_order_row_ids[index]
                    ar_invoice_request.rows.build(delivered_quantity: row.delivered_quantity, quantity: row.delivered_quantity, inward_dispatch_row_id: row.id, sales_order_id: inward_dispatch.sales_order.id, product_id: row.purchase_order_row.product_id, sales_order_row_id: sales_order_row_id)
                  end
                end
                if ar_invoice_request.valid?
                  ar_invoice_request.save
                  inward_dispatch.ar_invoice_request_id = ar_invoice_request.id
                  inward_dispatch.save
                  invoice_request.status = 'Inward Completed'
                  invoice_request.save
                else
                  status << {'id': x.id, error: x.errors.full_messages}
                end
              end
            end
          end
        end
      end
    end
  end
end
#
# PurchaseOrder.all.map{|x| if x.po_request.present?; po_products = x.rows.pluck(:product_id);so_products = x.po_request.sales_order.rows.pluck(:product_id);if(po_products.count > so_products.count);x.id;end;end}
#
#
# PurchaseOrder.all.map{|x| if x.po_request.present?; po_products = x.rows.pluck(:product_id).to_set;so_products = x.po_request.sales_order.rows.pluck(:product_id).to_set;if(!po_products.subset?(so_products));x.id;end;end}
#
# PurchaseOrder.all.map{|x| if x.po_request.present?; po_products = x.rows.pluck(:product_id).to_set;so_products = x.po_request.sales_order.rows.pluck(:product_id).to_set;if(!po_products.subset?(so_products));if (x.inquiry.status == 'Order Won');x.id;end;end;end}.compact
#