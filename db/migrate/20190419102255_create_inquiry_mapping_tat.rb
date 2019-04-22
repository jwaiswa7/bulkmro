class CreateInquiryMappingTat < ActiveRecord::Migration[5.2]
  def change
    create_table :inquiry_mapping_tats do |t|
      t.references :inquiry, foreign_key: true
      t.integer :sales_quote_id
      t.integer :sales_order_id
      t.timestamp :inquiry_created_at
    end
  end
end
