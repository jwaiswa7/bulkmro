class AddLostRegretReasonToInquiries < ActiveRecord::Migration[5.2]
  def change
    add_column :inquiries, :lost_regret_reason, :integer
  end
end
