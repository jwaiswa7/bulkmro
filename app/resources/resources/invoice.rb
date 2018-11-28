class Resources::Invoice < Resources::ApplicationResource

  def self.identifier
    :DocEntry
  end

  def self.update_invoice_items(invoice_record)
    response = self.custom_find(invoice_record.invoice_number)
    line_items = response['DocumentLines']
    sales_order = invoice_record.sales_order

    invoice_metadata = {
        :subtotal => response['DocTotal'] - response['VatSum'],
        :tax_amount => response['VatSum'],
        :subtotal_incl_tax => response['DocTotal']
    }

    invoice_record.update_attributes!(
        :metadata => invoice_metadata
    )
    #invoice_record.rows.destroy_all

    line_items.each do |remote_row|
      invoice_record.rows.create do |row|
        sales_order_row = sales_order.rows.joins(:product).where('products.sku = ?', remote_row['ItemCode']).first
        qty = remote_row['Quantity'].to_i
        unit_price = remote_row['Price'].to_f
        product = Product.find_by_sku(remote_row['ItemCode'])
        metadata = {
            :qty => qty,
            :sku => remote_row['ItemCode'],
            :name => remote_row['ItemDescription'],
            :price => unit_price,
            :base_cost => nil,
            :row_total => unit_price * qty,
            :base_price => unit_price,
            :product_id => product.id.to_param,
            :tax_amount => sales_order_row.calculated_tax * qty,
            :description => remote_row['ItemDescription'],
            :order_item_id => nil,
            :base_row_total => unit_price * qty,
            :price_incl_tax => nil,
            :additional_data => nil,
            :base_tax_amount => sales_order_row.calculated_tax * qty,
            :discount_amount => nil,
            :weee_tax_applied => nil,
            :hidden_tax_amount => nil,
            :row_total_incl_tax => (unit_price * qty) + (sales_order_row.calculated_tax * qty),
            :base_price_incl_tax => nil,
            :base_discount_amount => nil,
            :weee_tax_disposition => nil,
            :base_hidden_tax_amount => nil,
            :base_row_total_incl_tax => nil,
            :weee_tax_applied_amount => nil,
            :weee_tax_row_disposition => nil,
            :base_weee_tax_disposition => nil,
            :weee_tax_applied_row_amount => nil,
            :base_weee_tax_applied_amount => nil,
            :base_weee_tax_row_disposition => nil,
            :base_weee_tax_applied_row_amnt => nil
        }
        row.assign_attributes(
            quantity: remote_row['Quantity'],
            metadata: metadata
        )
      end
    end if line_items.present?

  end

  def self.custom_find(doc_num)

    response = get("/#{collection_name}?$filter=DocNum eq #{doc_num}")
    log_request(:get, 'Invoice - #{doc_num}', is_find: true)
    validated_response = get_validated_response(response)
    log_response(validated_response)

    if validated_response['value'].present?
      remote_record = validated_response['value'][0]
    end
    remote_record
  end
end