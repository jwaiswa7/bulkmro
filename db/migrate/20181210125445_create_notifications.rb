class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.integer :sender_id, index: true
      t.integer :recipient_id, index: true
      t.string :namespace
      t.string :action
      t.string :notifiable_type
      t.integer :notifiable_id
      t.text :message
      t.text :action_url
      t.jsonb :metadata
      t.datetime :read_at

      t.timestamps
    end
  end
end
