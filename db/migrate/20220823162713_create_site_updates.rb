class CreateSiteUpdates < ActiveRecord::Migration[5.2]
  def change
    create_table :site_updates do |t|
      t.timestamps
    end
  end
end
