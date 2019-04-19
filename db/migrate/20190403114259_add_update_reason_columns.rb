class AddUpdateReasonColumns < ActiveRecord::Migration[5.2]
  def change
    rename_column :invoice_requests, :rejection_reason, :grpo_rejection_reason
    rename_column :invoice_requests, :other_rejection_reason, :grpo_other_rejection_reason
    rename_column :invoice_requests, :cancellation_reason, :grpo_cancellation_reason

    add_column :invoice_requests, :ap_rejection_reason, :string
    add_column :invoice_requests, :ap_cancellation_reason, :string
  end
end
