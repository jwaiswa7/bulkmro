class CreateInquiryNumberSequence < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      CREATE SEQUENCE IF NOT EXISTS inquiry_number_seq;
    SQL
  end

  def down
    execute <<-SQL
      DROP SEQUENCE IF EXISTS inquiry_number_seq CASCADE;
    SQL
  end
end
