class CreateResyncRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :resync_requests do |t|
      t.text :request, array: true, default: []
      t.integer :status, default: 20

      t.timestamps
    end
  end
end
