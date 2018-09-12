class AddPositionColumnToInquiryProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :inquiry_products, :position, :integer
  end
end
