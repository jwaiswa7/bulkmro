class AddSuccessfulSkusToInquiryImports < ActiveRecord::Migration[5.2]
  def change
    add_column :inquiry_imports, :successful_skus_metadata, :jsonb
  end
end
