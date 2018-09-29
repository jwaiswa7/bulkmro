class CreateRemoteExchangeLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :remote_exchange_logs do |t|
      t.references :inquiry

      t.integer :method
      t.string :resource
      t.text :url
      t.text :request_message
      t.text :response_message
      t.integer :status

      t.timestamps
    end
  end
end
