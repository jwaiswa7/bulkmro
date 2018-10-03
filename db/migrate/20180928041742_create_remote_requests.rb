class CreateRemoteRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :remote_requests do |t|
      t.references :inquiry

      t.integer :status
      t.integer :method

      t.string :resource
      t.text :url
      t.jsonb :request
      t.jsonb :response

      t.timestamps
    end
  end
end
