class Services::Shared::Migrations::OutwardQueMigration < Services::Shared::Migrations::Migrations
  def addAssociationInInwardDisapatch
    InwardDispatch.all.each do |inward_dispatch|
      purchase_order = inward_dispatch.purchase_order
      sales_order = purchase_order.try(:po_request).try(:sales_order)
      if sales_order.present?
        Chewy.strategy(:bypass) do
          inward_dispatch.sales_order = sales_order
          inward_dispatch.save(validate: false)
        end
      end
    end
  end

  def add_product_row_in_inward_dispatch
    InwardDispatchRow.where(product_id: nil).each do |inward_dispatch_row|
      Chewy.strategy(:bypass) do
        inward_dispatch_row.product = inward_dispatch_row.purchase_order_row.product
        inward_dispatch_row.save(validate: false)
      end
    end
    # purchase_order_row_don't have product
    # [39440, 40603, 40878, 41116, 41554, 41260, 41259, 42137, 29509, 42454, 42795, 42794, 41355, 43246, 42372, 43797, 42901, 41486, 44741, 44902]


    SalesOrderRow.all.each do |sales_order_row|
      Chewy.strategy(:bypass) do
        sales_order_row.product_id = sales_order_row.product.id
        sales_order_row.save(validate: false)
      end
    end
  end

  # def createArInvoiceAndRows
  #   status = []
  #   InvoiceRequest.all.each do |invoice_request|
  #     if invoice_request.status == 'Completed AR Invoice Request'
  #       if !invoice_request.ar_invoice_number.present?
  #         sales_invoice = SalesInvoice.where(invoice_number:invoice_request.ar_invoice_number).last
  #         if sales_invoice.present?
  #           ar_invoice_request = ArInvoiceRequest.where(sales_invoice_id: sales_invoice.invoice_number).last
  #           if !ar_invoice_request.present?
  #             Chewy.strategy(:bypass) do
  #             if invoice_request.inward_dispatches.present?
  #               inward_dispatch = invoice_request.inward_dispatches.last
  #               inward_dispatch_rows = inward_dispatch.rows
  #               if inward_dispatch.sales_order.present?
  #                 ar_invoice_request = ArInvoiceRequest.new(overseer: invoice_request.created_by, sales_order: inward_dispatch.sales_order, inquiry: inward_dispatch.inquiry, status: 'Completed AR Invoice Request', ar_invoice_number: invoice_request.ar_invoice_number)
  #                 sales_order_rows = inward_dispatch.sales_order.rows.order(:created_at)
  #                 sales_order_row_ids = sales_order_rows.pluck(:id)
  #                 product_ids = sales_order_rows.map{ |x| x.product.id}
  #                 inward_dispatch_rows.each do |row|
  #                   index = product_ids.index(row.purchase_order_row.product_id)
  #                   if index
  #                     sales_order_row_id = sales_order_row_ids[index]
  #                     ar_invoice_request.rows.build(delivered_quantity: row.delivered_quantity, quantity: row.delivered_quantity, inward_dispatch_row_id: row.id, sales_order_id: inward_dispatch.sales_order.id, product_id: row.purchase_order_row.product_id, sales_order_row_id: sales_order_row_id)
  #                   end
  #                 end
  #                 if ar_invoice_request.valid?
  #                   ar_invoice_request.save
  #                   inward_dispatch.ar_invoice_request_id = ar_invoice_request.id
  #                   inward_dispatch.save(validate: false)
  #                   invoice_request.status = 'Inward Completed'
  #                   invoice_request.save
  #                 else
  #                   status << {'id': x.id, error: x.errors.full_messages}
  #                 end
  #               end
  #             end
  #             end
  #           else
  #           end
  #         else
  #           status << {invoice_request_id: invoice_request.id, error: 'sales invoice_not present #{invoice_request.ar_invoice_number}'}
  #         end
  #     end
  #     end
  #   end
  # end
  #
  def csv_for_wrong_entry
    data = []
    invoice_requests = InvoiceRequest.where(status: ['Completed AR Invoice Request']).group_by(&:ar_invoice_number)
    invoice_requests.each do |key, val|
      if key.present?
        sales_invoice = SalesInvoice.where(invoice_number: key).last
        if sales_invoice.present? && val.length > 1
          number_array = []
          invoice_request_array = []
          val.each do |invoice_request|
            number_array << invoice_request.inquiry.inquiry_number
            invoice_request_array << invoice_request.id
          end
          uniq_number_array = number_array.uniq
          if uniq_number_array.length > 1
            data << {req_id: invoice_request_array * ',', ar_invoice_number: key, sales_invoice_inquiry_number: sales_invoice.inquiry.inquiry_number, inquiry_number: uniq_number_array * ',' }
          end
        elsif sales_invoice.present? && val.length == 1
          if sales_invoice.inquiry != val[0].inquiry
            data << {req_id: val[0].id, ar_invoice_number: key, sales_invoice_inquiry_number: sales_invoice.inquiry.inquiry_number, inquiry_number: val[0].inquiry.inquiry_number }
          end
        else
          val.each do |invoice_request|
            data << {req_id: invoice_request.id, ar_invoice_number: key, sales_invoice_inquiry_number: '-', inquiry_number: invoice_request.inquiry.inquiry_number}
          end
        end
      end
    end
  end
  def createArInvoiceAndRows
    invoice_requests = InvoiceRequest.where(status: 'Completed AR Invoice Request').group_by(&:ar_invoice_number)
    invoice_requests.each do |key, val|
      if key.present?
        sales_invoice = SalesInvoice.where(invoice_number: key).last
        if sales_invoice.present?
          ar_invoice_request = ArInvoiceRequest.where(sales_invoice_id: sales_invoice.id).last
          inquiry_ids = val.pluck(:inquiry_id).uniq
          # SO --> AR many to one
          sales_order_ids = val.pluck(:sales_order_id).uniq
          if !ar_invoice_request.present? && (inquiry_ids.count == 1) && (sales_order_ids.count == 1)
            Chewy.strategy(:bypass) do
              inward_dispatch_array = val.map {|x| x.inward_dispatches}.flatten
              if inward_dispatch_array.length > 0
                ar_invoice_request = ArInvoiceRequest.new(overseer: val[0].created_by, sales_order_id: sales_order_ids[0], inquiry_id: inquiry_ids[0], status: 'Completed AR Invoice Request', sales_invoice_id: sales_invoice.id)
                # data_present = val.map{|x| x.inward_dispatches.count > 0 && (x.inward_dispatches.map{|y| y.rows.count}.flatten.compact.sum > 0)}
                ar_invoice_request.save!
                val.each do |invoice_request|
                  invoice_request.status = 'Inward Completed'
                  invoice_request.save(validate: false)
                  if invoice_request.inward_dispatches.present?
                    # invoice_request.inward_dispatches.map { |d|  d.ar_invoice_request_id= ar_invoice_request.id; d.save(validate: false)}
                    inward_dispatch_rows = invoice_request.inward_dispatches.map {|x| x.rows}.flatten
                    inward_dispatch_rows.each do |row|
                      sales_order_row = SalesOrderRow.where(sales_order_id: sales_order_ids[0]).joins(:product).where(products: {id: row.purchase_order_row.product_id}).last
                      if sales_order_row.present?
                        row_product = ar_invoice_request.rows.where(product_id: row.purchase_order_row.product_id, sales_order_id: sales_order_ids[0], sales_order_row_id: sales_order_row.id).last
                        if !row_product
                          row_product = ar_invoice_request.rows.where(product_id: row.purchase_order_row.product_id, sales_order_id: sales_order_ids[0], sales_order_row_id: sales_order_row.id).first_or_initialize
                          row_product.delivered_quantity = row.delivered_quantity
                          row_product.quantity = sales_order_row.quantity
                          row_product.sales_order_id = sales_order_ids[0]
                          row_product.sales_order_row_id = sales_order_row.id
                          row_product.save(validate: false)

                        else
                          row_product.delivered_quantity = row_product.delivered_quantity + row.delivered_quantity
                          row_product..save(validate: false)
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  def add_association_of_sales_invoice
    invoice_request_ids = []
    invoice_requests =  InvoiceRequest.where.not(ar_invoice_number: nil)
    invoice_requests.each do |invoice_request|
      sales_invoice = SalesInvoice.where(invoice_number:  invoice_request.ar_invoice_number).last
      if sales_invoice.present? && (invoice_request.inquiry == invoice_request.inquiry)
        invoice_request.sales_invoice_id = sales_invoice.id
        invoice_request.save(validate: false)
      else
        invoice_request_ids << invoice_request.id
      end
    end
  end

  def set_ar_invoice_request_status
    inward_dispatches = InwardDispatch.joins(:invoice_request).where(invoice_requests: {status: 'Inward Completed'}, status: 'Material Delivered').where(ar_invoice_request_id: nil)
    inward_dispatches.update_all(ar_invoice_request_status: 'Not Requested')
    inward_dispatches = InwardDispatch.where.not(ar_invoice_request_id: nil)
    inward_dispatches.each do |inward_dispatch|
      ar_invoice_request = inward_dispatch.ar_invoice_request
      if ar_invoice_request.present?
        case ar_invoice_request.status
        when 'AR Invoice requested'
          inward_dispatch.ar_invoice_request_status = 'Requested'
        when 'Cancelled AR Invoice'
          inward_dispatch.ar_invoice_request_status = 'Cancelled AR Invoice'
        when 'AR Invoice Request Rejected'
          inward_dispatch.ar_invoice_request_status = 'Rejected'
        when 'Completed AR Invoice Request'
          inward_dispatch.ar_invoice_request_status = 'Completed'
        end
        inward_dispatch.save(validate: false)
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
