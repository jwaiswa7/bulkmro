class RenamePodAttachmentToPodAttachments < ActiveRecord::Migration[5.2]
  def change
    rename_column :sales_invoices, :pod_attachment, :pod_attachments
  end
end
