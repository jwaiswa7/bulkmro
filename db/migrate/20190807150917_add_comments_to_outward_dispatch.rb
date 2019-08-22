class AddCommentsToOutwardDispatch < ActiveRecord::Migration[5.2]
  def change
    create_table :outward_dispatch_comments do |t|
      t.references :outward_dispatch, foreign_key: true
      t.text :message

      t.userstamps
      t.timestamps
    end
  end
end
