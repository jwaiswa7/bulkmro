class AddBpCatalogNameAndBpCatalogSkuToPoRequestRows < ActiveRecord::Migration[5.2]
  def change
    add_column :po_request_rows, :bp_catalog_name, :string
    add_column :po_request_rows, :bp_catalog_sku, :string
  end
end
