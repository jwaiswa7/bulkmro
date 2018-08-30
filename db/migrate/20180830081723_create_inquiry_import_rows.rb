class CreateInquiryImportRows < ActiveRecord::Migration[5.2]
  def change
    create_table :inquiry_import_rows do |t|
      t.references :inquiry_import
      t.references :inquiry_product

      t.string :sku
      t.jsonb :metadata

      t.timestamps
    end
  end
end
