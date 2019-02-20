class Services::Overseers::Exporters::PurchaseOrdersExporter < Services::Overseers::Exporters::BaseExporter
  def initialize(headers)
    @file_name = 'purchase_orders'
    super(headers, @file_name)
    @model = PurchaseOrder
    @columns = %w(po_number inquiry_number inquiry_date company_name inside_sales procurement_date order_number order_date order_status po_date po_status supplier_name payment_terms committed_customer_date supplier_phone_no supplier_email route_through ship_from ship_to)
    @columns.each do |column|
      rows.push(column)
    end
  end

  def call
    build_csv
  end

  def build_csv
    Enumerator.new do |yielder|
      yielder << CSV.generate_line(rows)
      model.where(created_at: start_at..end_at).order(po_number: :asc).each do |purchase_order|
        inquiry = purchase_order.inquiry

        row = {
            po_number: purchase_order.po_number.to_s,
            inquiry_number: inquiry.inquiry_number.to_s,
            inquiry_date: inquiry.created_at.to_date.to_s,
            company_name: inquiry.company.name.gsub(';', ''),
            inside_sales: (inquiry.inside_sales_owner.present? ? inquiry.inside_sales_owner.try(:full_name) : nil)
        }

        row.merge!(
          if inquiry.procurement_date.present?
            { procurement_date: inquiry.procurement_date.to_date.to_s }
          else
            { procurement_date: nil }
          end
        )

        supplier = purchase_order.get_supplier(purchase_order.rows.first.metadata['PopProductId'].to_i)

         sales_order = inquiry.sales_orders.remote_approved.each do |sales_order|
          ids = []

          sales_order.rows.each do |r|
            ids.push(r.sales_quote_row.inquiry_product_supplier.supplier.id)
          end

          if ids.include?(supplier.id)
            sales_order
          else
            nil
          end
        end.try(:first) if supplier.present?

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
            { payment_terms: inquiry.payment_option.name }
          else
            { payment_terms: nil }
          end
        )

        row.merge!(
          committed_customer_date: (inquiry.customer_committed_date.present? ? inquiry.customer_committed_date.to_date.to_s : nil)
        )

        supplier_phone = if supplier.present?
          if supplier.phone.present? && supplier.mobile.present?
            supplier.phone + '/' + supplier.mobile
          elsif supplier.mobile.present?
            supplier.mobile
          else
            supplier.phone
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
      rows.drop(columns.count).each do |row|
        yielder << CSV.generate_line(row.values)
      end
    end
  end
end
