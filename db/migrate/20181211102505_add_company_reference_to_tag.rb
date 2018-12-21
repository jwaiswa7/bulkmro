class AddCompanyReferenceToTag < ActiveRecord::Migration[5.2]
  def change
    add_reference :tags, :company, foreign_key: true
  end
end
