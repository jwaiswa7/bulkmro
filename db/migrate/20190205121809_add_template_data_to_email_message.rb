class AddTemplateDataToEmailMessage < ActiveRecord::Migration[5.2]
  def change
    add_column :email_messages, :template_data, :jsonb
  end
end
