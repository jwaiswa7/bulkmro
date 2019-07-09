class AddDispatchFieldsToOutwardDispatches < ActiveRecord::Migration[5.2]
  def change
    add_column :outward_dispatches, :dispatch_date, :datetime
    add_column :outward_dispatches, :expected_date_of_delivery, :datetime
    add_column :outward_dispatches, :actual_delivery_date, :datetime
   # Dispatched By, Docket Details
  end
end
