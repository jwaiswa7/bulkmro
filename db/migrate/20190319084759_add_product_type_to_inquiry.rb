class AddProductTypeToInquiry < ActiveRecord::Migration[5.2]
  def change
    add_column :inquiries, :product_type, :integer
  end
end
