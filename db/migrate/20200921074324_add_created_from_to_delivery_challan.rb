class AddCreatedFromToDeliveryChallan < ActiveRecord::Migration[5.2]
  def change
  	add_column :delivery_challans, :created_from, :string 
  end
end
