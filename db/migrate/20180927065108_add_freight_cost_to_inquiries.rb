class AddFreightCostToInquiries < ActiveRecord::Migration[5.2]
  def change
    add_column :inquiries, :freight_cost, :decimal
  end
end
