class CreateInquiryImports < ActiveRecord::Migration[5.2]
  def change
    create_table :inquiry_imports do |t|
      t.references :inquiry

      t.integer :import_type
      t.text :import_text

      t.timestamps
      t.userstamps
    end
  end
end
