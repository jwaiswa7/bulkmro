class Resources::ProductTree < Resources::ApplicationResource
  def self.identifier
    :TreeCode
  end

  def self.to_remote(record)
    kit_items = []
    record.kit_product_rows.each do |kit_product|
      kit_product_row = OpenStruct.new
      kit_product_row.ItemCode = kit_product.product.remote_uid
      kit_product_row.Project = record.inquiry.inquiry_number
      kit_product_row.Quantity = kit_product.quantity
      kit_product_row.Warehouse = record.inquiry.ship_from.remote_uid
      kit_items.push(kit_product_row.marshal_dump)
    end

    params = {
        TreeCode: record.product.sku,
        TreeType: 'iSalesTree',
        Project: record.inquiry.inquiry_number,
        Quantity: 1, # record.quantity,
        Warehouse: record.inquiry.ship_from.remote_uid,
        HideBOMComponentsInPrintout: 'tNO',
        ProductTreeLines: kit_items,
    }

    params
  end
end
