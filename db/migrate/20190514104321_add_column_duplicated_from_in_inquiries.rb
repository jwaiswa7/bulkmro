class AddColumnDuplicatedFromInInquiries < ActiveRecord::Migration[5.2]
  def change
    add_column :inquiries, :duplicated_from, :integer
  end
end
