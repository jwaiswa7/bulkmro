class CreateDeliveryChallanComments < ActiveRecord::Migration[5.2]
  def change
    create_table :delivery_challan_comments do |t|
    	t.references :delivery_challan, foreign_key: true

    	t.text :message

    	t.userstamps
      t.timestamps
    end
  end
end
