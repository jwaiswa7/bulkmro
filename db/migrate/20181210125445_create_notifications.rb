class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.references :overseer, index: true
      t.integer :recipient_id
      t.string :action
      t.string :notifiable_type
      t.integer :notifiable_id
      t.text :message
      t.datetime :read_at

      t.timestamps
    end
  end
end
