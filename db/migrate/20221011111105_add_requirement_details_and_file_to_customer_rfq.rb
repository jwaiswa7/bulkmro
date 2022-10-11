class AddRequirementDetailsAndFileToCustomerRfq < ActiveRecord::Migration[5.2]
  def change
    add_column :customer_rfqs, :requirement_details, :text
    add_column :customer_rfqs, :file, :string
  end
end
