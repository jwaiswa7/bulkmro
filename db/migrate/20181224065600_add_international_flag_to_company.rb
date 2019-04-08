class AddInternationalFlagToCompany < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :is_international, :boolean
  end
end
