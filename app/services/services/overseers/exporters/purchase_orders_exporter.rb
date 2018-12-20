class Services::Overseers::Exporters::PurchaseOrdersExporter < Services::Overseers::Exporters::BaseExporter
  def initialize
    super
    @model = PurchaseOrder
    @export_name = 'purchase_orders'
    @path = Rails.root.join('tmp', filename)
    @columns = %w(po_number inquiry_number inquiry_date company_name inside_sales procurement_date order_number order_date order_status po_date po_status supplier_name payment_terms committed_customer_date)
  end

  def call
    perform_export_later('PurchaseOrdersExporter')
  end

  def build_csv
    model.where(:created_at => start_at..end_at).order(po_number: :asc).each do |purchase_order|
      inquiry = purchase_order.inquiry

      row = {
          :po_number => purchase_order.po_number.to_s,
          :inquiry_number => inquiry.inquiry_number.to_s,
          :inquiry_date => inquiry.created_at.to_date.to_s,
          :company_name => inquiry.company.name,
          :inside_sales => ( inquiry.inside_sales_owner.present? ? inquiry.inside_sales_owner.to_s : nil )
      }

      row.merge!(
          if inquiry.procurement_date.present?
            {:procurement_date => inquiry.procurement_date.to_date.to_s}
          else
            {:procurement_date => nil}
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
                :order_number => sales_order.order_number.to_s,
                :order_date => sales_order.created_at.to_date.to_s,
                :order_status => sales_order.remote_status,
                :po_date => purchase_order.created_at.to_date.to_s,
                :po_status => nil,
                :supplier_name => supplier.name
            }
          else
            {
                :order_number => nil,
                :order_date => nil,
                :order_status => nil,
                :po_date => purchase_order.created_at.to_date.to_s,
                :po_status => nil,
                :supplier_name => nil
            }
          end
      )

      row.merge!(
          if inquiry.payment_option.present?
            {:payment_terms => inquiry.payment_option.name}
          else
            {:payment_terms => nil}
          end
      )

      row.merge!(
             {:committed_customer_date => ( inquiry.customer_committed_date.present? ? inquiry.customer_committed_date.to_date.to_s : nil )}
      )


      rows.push(row)
    end
    export = Export.create!(export_type: 15)
    generate_csv(export)
  end
end