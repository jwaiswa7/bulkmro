class CreateInquiryImportRows < ActiveRecord::Migration[5.2]
  def change
    create_table :inquiry_import_rows do |t|
      t.references :inquiry_import, foreign_key: true
      t.references :inquiry_product, foreign_key: true, on_delete: :nullify

      t.string :sku
      t.jsonb :metadata

      t.timestamps
    end
  end
end
