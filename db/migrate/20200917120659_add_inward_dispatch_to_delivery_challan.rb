class AddInwardDispatchToDeliveryChallan < ActiveRecord::Migration[5.2]
  def change
  	add_reference :delivery_challans, :inward_dispatch, index: true
  end
end
