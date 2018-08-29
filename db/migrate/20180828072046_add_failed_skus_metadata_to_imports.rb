class AddFailedSkusMetadataToImports < ActiveRecord::Migration[5.2]
  def change
    add_column :inquiry_imports, :failed_skus_metadata, :jsonb
  end
end
