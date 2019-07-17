class AddDispatchFieldsToOutwardDispatches < ActiveRecord::Migration[5.2]
  def change
    add_column :outward_dispatches, :material_dispatch_date, :datetime
    add_column :outward_dispatches, :expected_date_of_delivery, :datetime
    add_column :outward_dispatches, :material_delivery_date, :datetime
    add_column :outward_dispatches, :dispatched_by, :string
    add_column :outward_dispatches, :dispatch_mail_sent_to_the_customer, :boolean
    add_column :outward_dispatches, :logistics_partner, :string
    add_column :outward_dispatches, :tracking_number, :string
    add_column :outward_dispatches, :material_delivered_mail_sent_to_customer, :boolean
  end
end
