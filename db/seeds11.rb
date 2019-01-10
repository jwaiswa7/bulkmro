def generate_csv(objects,columns,name= "po_export_")
  file = "#{Rails.root}/public/#{name}_#{Date.today.to_s}.csv"
  CSV.open(file, 'w', write_headers: true, headers: columns) do |writer|
    objects.each do |object|
      writer << object.values
    end
  end
end


def get_purchase_order
  start_at = Date.new(2018, 10, 19)
  end_at = Date.today.end_of_day
  rows = []
  columns = %w(po_number inquiry_number inquiry_date company_name inside_sales procurement_date order_number order_date order_status po_date po_status supplier_name payment_terms committed_customer_date)
  model = PurchaseOrder
  objects = model.where(:created_at => start_at..end_at).order(po_number: :asc).each do |purchase_order|
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

  rows
end

objects = get_purchase_order

columns = %w(po_number inquiry_number inquiry_date company_name inside_sales procurement_date order_number order_date order_status po_date po_status supplier_name payment_terms committed_customer_date)

generate_csv(objects,columns,name= "po_export_")

