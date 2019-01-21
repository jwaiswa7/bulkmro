class AddSellingPriceToPoRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :po_requests, :converted_total_selling_price, :decimal
  end
end
