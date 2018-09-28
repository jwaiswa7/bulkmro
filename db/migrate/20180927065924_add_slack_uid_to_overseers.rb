class AddSlackUidToOverseers < ActiveRecord::Migration[5.2]
  def change
    add_column :overseers, :slack_uid, :string
  end
end
