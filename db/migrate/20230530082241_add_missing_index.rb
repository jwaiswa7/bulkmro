class AddMissingIndex < ActiveRecord::Migration[5.2]
  def change
    #add_index :customer_products, [:company_id, :sku], unique: false
    #add_index :company_reviews, [:company_id, :survey_type, :created_by_id], unique: false, name: 'index_on_company_review'
    add_index :inquiries, :opportunity_uid, unique: false
    add_index :purchase_orders, :po_number, unique: false
  end
end
