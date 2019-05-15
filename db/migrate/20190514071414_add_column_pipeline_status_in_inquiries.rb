class AddColumnPipelineStatusInInquiries < ActiveRecord::Migration[5.2]
  def change
    add_column :inquiries, :pipeline_status, :integer
  end
end
