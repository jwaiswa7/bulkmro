class AddInternationalFlagToCompany < ActiveRecord::Migration[5.2]
  def change
    add_column :company, :is_international, :boolean
  end
end
