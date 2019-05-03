class AddLegacyOptionIdToBrand < ActiveRecord::Migration[5.2]
  def change
    add_column :brands, :legacy_option_id, :integer
  end
end
