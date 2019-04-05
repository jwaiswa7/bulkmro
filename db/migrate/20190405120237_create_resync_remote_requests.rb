class CreateResyncRemoteRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :resync_remote_requests do |t|
      t.references :subject, polymorphic: true

      t.integer :status
      t.integer :hits
      t.integer :method

      t.string :resource
      t.text :url
      t.jsonb :request
      t.jsonb :response

      t.userstamps
      t.timestamps
    end
  end
end
