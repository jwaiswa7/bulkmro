class AddCalculatedTotalToInquiries < ActiveRecord::Migration[5.2]
  def change
    add_column :inquiries, :calculated_total, :decimal
  end
end
