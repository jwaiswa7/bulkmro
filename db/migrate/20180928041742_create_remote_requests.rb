class CreateRemoteRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :remote_requests do |t|
      t.references :subject, polymorphic: true

      t.integer :status
      t.integer :method

      t.boolean :is_find
      t.string :resource
      t.text :url
      t.jsonb :request
      t.jsonb :response

      t.userstamps
      t.timestamps
    end

  end
end
