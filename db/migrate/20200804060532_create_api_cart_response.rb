class CreateApiCartResponse < ActiveRecord::Migration[5.2]
  def change
    create_table :api_cart_responses do |t|
      t.string :buyer_cookie
      t.text :payload
      t.string :api_endpoint
      t.string :response_status
      t.references :api_request, foreign_key: :true
    end
  end
end
