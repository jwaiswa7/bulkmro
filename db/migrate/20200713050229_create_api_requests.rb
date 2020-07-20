class CreateApiRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :api_requests do |t|
      t.string :endpoint
      t.string :payload
      t.string :request_header
      t.string :response
      t.string :error_message
      t.string :contact_email
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
