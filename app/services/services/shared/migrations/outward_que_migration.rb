class Services::Shared::Migrations::OutwardQueMigration < Services::Shared::Migrations::Migrations
  # 1. Migration for connect Inward and SalesOrder
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

  # 2. Migration for connect product with inward_dispatch and sales_order
  def add_product_row_in_inward_dispatch
    InwardDispatchRow.where(product_id: nil).each do |inward_dispatch_row|
      Chewy.strategy(:bypass) do
        inward_dispatch_row.product = inward_dispatch_row.purchase_order_row.product
        inward_dispatch_row.save(validate: false)
      end
    end
    # purchase_order_row_don't have product
    # [39440, 40603, 40878, 41116, 41554, 41260, 41259, 42137, 29509, 42454, 42795, 42794, 41355, 43246, 42372, 43797, 42901, 41486, 44741, 44902]


    SalesOrderRow.where(product_id: nil).each do |sales_order_row|
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

  # 3. Creation for ArInvoiceRequest and its rows
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
                  # invoice_request.status = 'Inward Completed'
                  # invoice_request.save(validate: false)
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
    # InvoiceRequest.where(status: 'Completed AR Invoice Request').update_all(status: 'Inward Completed')
  end

  # 4. Associations added for sales_invoice and invoice request
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


  def status_changed_to_manually_closed
    po_numbers = [40210166, 40212000, 40212460, 40212614, 40212666, 40212730, 40212823, 40212939, 40212971, 40212991, 40213018, 40213100, 40213114, 40213173, 40213180, 40213184, 40213186, 40610914, 40610943, 40610946, 40610948, 40610994, 40611004, 40611037, 40611066, 41210155, 41210181, 41410274, 41410298, 402000008, 402000011, 402000019, 402000031, 402000065, 402000073, 402000081, 402000083, 402000088, 402000099, 402000165, 402000178, 402000240, 402000248, 402000256, 402000280, 402000291, 402000295, 402000328, 402000329, 402000339, 402000343, 402000347, 402000364, 402000391, 402000393, 402000425, 402000438, 402000441, 402000580, 402000613, 402000648, 402000655, 402000657, 402000707, 402000733, 402000746, 402000907, 402000913, 402000939, 402000953, 402000972, 402000991, 402001024, 402001032, 402001033, 402001054, 402001059, 402001063, 402001064, 402001073, 402001074, 402001090, 402001137, 402001165, 402001166, 402001200, 402001236, 402001349, 404000015, 404000064, 404000092, 404000097, 404000098, 404000104, 404000119, 404000126, 404000136, 404000195, 404000208, 404000221, 404000236, 405000013, 405000033, 405000041, 405000047, 405000084, 405000096, 405000100, 405000124, 406000023, 407000033, 407000037, 407000062, 408000010, 408000053, 408000068, 402001115, 402001347, 402000013, 405000097]
    purchase_orders = PurchaseOrder.where(po_number: po_numbers)
    purchase_orders.update_all(material_status: 'Manually Closed')
  end

  def insert_inward_dispatch_ids
    delivered_inward_dispatches = InwardDispatch.where(status: 'Material Delivered')
    delivered_inward_dispatches.each do |inward_dispatch|
      if inward_dispatch.is_inward_completed?
        ar_invoices = inward_dispatch.show_ar_invoice_requests
        if ar_invoices.present?
          if ar_invoices.count == 1
            sales_order = inward_dispatch.sales_order
            ar_invoice = ar_invoices.last
            ar_invoice_id = ar_invoice.id
            ar_invoice_ids = []
            if sales_order.present?
              inward_dispatches = InwardDispatch.where(sales_order_id: sales_order.id).where.not(id: inward_dispatch.id)
              ar_invoice_ids = inward_dispatches.map {|x| if x.show_ar_invoice_requests.pluck(:id).include? ar_invoice_id; x.id; end}.compact
            end
            ar_invoice_ids << inward_dispatch.id
            ar_invoice.inward_dispatch_ids = ar_invoice_ids
            ar_invoice.save
          else
          end
        end
      end
      # delivered_inward_dispatches.map{|x| if x.is_inward_completed? && x.show_ar_invoice_requests.count > 1;[x.rows.count,x.show_ar_invoice_requests.map{|y| y.rows.count}];end;}.compact
    end
  end

  def multiple_inward_ids
    invoice_ids = []
    none_ids = []
    service = Services::Shared::Spreadsheets::CsvImporter.new('inward_dispatch_ids.csv', 'seed_files_3')
    service.loop(nil) do |x|
      invoice = ArInvoiceRequest.where(id: x.get_column('ar_invoice_id')).last
      if invoice.present?
        invoice.inward_dispatch_ids = x.get_column('inward_ids').split(',').map {|x| x.to_i}
        invoice.save!
        invoice_ids << invoice.id
      else
        none_ids << x.get_column('ar_invoice_id')
      end
    end
  end
end
