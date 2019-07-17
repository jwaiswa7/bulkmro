class Services::Shared::Migrations::FixShipmentRows < Services::Shared::Migrations::Migrations
  def add_sku_rows
    SalesShipment.all.order(id: :desc).each do |ss|
      if ss.metadata.present?
        item_lines =  ss.metadata['ItemLine'] if ss.metadata['ItemLine'].present?
        if item_lines.present?
          item_lines.each do |line_item|
            puts line_item['sku']
            ss.rows.where(sku: line_item['sku']).first_or_create! do |row|
              row.assign_attributes(
                  quantity: line_item['qty'],
                  metadata: line_item
              )
            end
          end
        end
      end
    end
  end
end

