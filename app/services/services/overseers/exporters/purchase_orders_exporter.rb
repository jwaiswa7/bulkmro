class Services::Overseers::Exporters::PurchaseOrdersExporter < Services::Overseers::Exporters::BaseExporter

  def initialize
    super

    @columns = %w(po_number po_date inquiry_number inquiry_date company_name payment_terms procurement_date order_number order_date order_status supplier_name)
    @model = PurchaseOrder
  end

  def call
    model.where(:created_at => start_at..end_at).each do |purchase_order|
      inquiry = purchase_order.inquiry

      row = {
          :po_number => purchase_order.po_number.to_s,
          :po_date => purchase_order.created_at.to_date.to_s,
          :inquiry_number => inquiry.inquiry_number.to_s,
          :inquiry_date => inquiry.created_at.to_date.to_s,
          :company_name => inquiry.company.name
      }

      row.merge(
          if inquiry.payment_option.present?
            {:payment_terms => inquiry.payment_option.name}
          else
            {:payment_terms => nil}
          end
      )

      row.merge(
          if inquiry.procurement_date.present?
            {:procurement_date => inquiry.procurement_date.to_date.to_s}
          else
            {:procurement_date => nil}
          end
      )

      supplier = purchase_order.get_supplier(purchase_order.rows.first.metadata['PopProductId'].to_i)
      sales_order = inquiry.sales_orders.each do |sales_order|
        ids = []

        sales_order.rows.each do |r|
          ids.push(r.sales_quote_row.inquiry_product_supplier.supplier.id)
        end

        if ids.include?(supplier.id)
          sales_order
        else
          nil
        end
      end if supplier.present?

      row.merge({
                    :order_number => sales_order.order_number.to_s,
                    :order_date => sales_order.created_at.to_date.to_s,
                    :order_status => sales_order.status,
                    :supplier_name => supplier.name
                }) if supplier.present? && sales_order.present?

      rows.push(row)
    end

    generate_csv
  end
end