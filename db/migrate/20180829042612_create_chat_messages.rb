class CreateChatMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :chat_messages do |t|
      t.string :to
      t.string :from

      t.text :message
      t.jsonb :metadata

      t.timestamps
    end
  end
end
