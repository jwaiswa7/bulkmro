class Services::Overseers::Exporters::PurchaseOrdersExporter < Services::Overseers::Exporters::BaseExporter
  def initialize(*params)
    super(*params)
    @model = PurchaseOrder
    @export_name = 'purchase_orders'
    @path = Rails.root.join('tmp', filename)
    @columns = %w(po_number inquiry_number inquiry_date company_name inside_sales procurement_date order_number order_date order_status po_date po_status supplier_name payment_terms committed_customer_date supplier_phone_no supplier_email route_through ship_from ship_to)
  end

  def call
    perform_export_later('PurchaseOrdersExporter', @arguments)
  end

  def build_csv
    @export_time['creation'] = Time.now
    ExportMailer.export_notification_mail(@export_name, true, @export_time).deliver_now
    po_with_no_po_requests = []
    if @ids.present?
      records = model.where(id: @ids).order(created_at: :desc)
    else
      records = model.where(created_at: start_at..end_at).order(po_number: :asc)
    end

    @export = Export.create!(export_type: 15, status: 'Processing', filtered: @ids.present?, created_by_id: @overseer.id, updated_by_id: @overseer.id)
    records.find_each(batch_size: 100) do |purchase_order|
      inquiry = purchase_order.inquiry

      row = {
          po_number: purchase_order.po_number.to_s,
          inquiry_number: inquiry.inquiry_number.to_s,
          inquiry_date: inquiry.created_at.to_date.to_s,
          company_name: inquiry.company.name.gsub(';', ''),
          inside_sales: (inquiry.inside_sales_owner.present? ? inquiry.inside_sales_owner.try(:full_name) : nil),
          procurement_date: inquiry.procurement_date.present? ? inquiry.procurement_date.to_date.to_s : nil,
      }

      blank_po_rows = purchase_order.rows.blank?
      supplier = if blank_po_rows
        ''
      elsif purchase_order.is_legacy
        purchase_order.get_supplier(purchase_order.rows.first.metadata['PopProductId'].to_i)
      else
        purchase_order.supplier
      end

      sales_order = if blank_po_rows
        nil
      elsif supplier.present? && purchase_order.is_legacy?
        inquiry.sales_orders.remote_approved.each do |sales_order|
          ids = []

          sales_order.rows.each do |r|
            ids.push(r.sales_quote_row.inquiry_product_supplier.supplier.id)
          end

          if ids.include?(supplier.id)
            sales_order
          else
            nil
          end
        end.try(:first)
      else
        begin
          purchase_order.po_request.sales_order
        rescue Exception => e
          # po attached to wrong inquiries are pushed and can be found in this array
          po_with_no_po_requests.push(purchase_order.po_number)
          puts "PO REQUEST MISSING in #{purchase_order}, #{e}"
        end
      end

      row.merge!(
        if supplier.present? && sales_order.present?
          {
              order_number: sales_order.order_number.to_s,
              order_date: sales_order.created_at.to_date.to_s,
              order_status: sales_order.remote_status,
              po_date: (purchase_order.metadata['PoDate'].to_date.strftime('%d-%b-%Y').to_s if purchase_order.metadata['PoDate'].present? && purchase_order.valid_po_date?) || nil,
              po_status: nil,
              supplier_name: supplier.name
          }
        else
          {
              order_number: nil,
              order_date: nil,
              order_status: nil,
              po_date: (purchase_order.metadata['PoDate'].to_date.strftime('%d-%b-%Y').to_s if purchase_order.metadata['PoDate'].present? && purchase_order.valid_po_date?) || nil,
              po_status: nil,
              supplier_name: nil
          }
        end
      )

      row.merge!(
        if inquiry.payment_option.present?
          {payment_terms: inquiry.payment_option.name}
        else
          {payment_terms: nil}
        end
      )

      row.merge!(
        committed_customer_date: (inquiry.customer_committed_date.present? ? inquiry.customer_committed_date.to_date.to_s : nil)
      )

      supplier_phone = if supplier.present?
        if supplier.telephone.present? && supplier.mobile.present?
          supplier.telephone + '/' + supplier.mobile
        elsif supplier.mobile.present?
          supplier.mobile
        else
          supplier.telephone
        end
      else
        nil
      end

      row.merge!(
        if supplier.present?
          {
              supplier_phone_no: supplier_phone,
              supplier_email: (supplier.legacy_email || supplier.email)
          }
        else
          {
              supplier_phone_no: nil,
              supplier_email: nil
          }
        end
      )

      row.merge!(
        if inquiry.present?
          {
              route_through: inquiry.try(:opportunity_type),
              ship_from: inquiry.ship_from.present? ? inquiry.ship_from.address.city_name : nil,
              ship_to: inquiry.shipping_address.present? ? inquiry.shipping_address.city_name : nil
          }
        else
          {
              route_through: nil,
              ship_from: nil,
              ship_to: nil
          }
        end
      )

      rows.push(row)
    end

    @export.update_attributes(status: 'Completed')
    generate_csv(@export)
    puts 'ERRORS', po_with_no_po_requests
  end
end
