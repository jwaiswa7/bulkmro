class CreateInquiryNumberSequence < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      CREATE SEQUENCE inquiry_number_seq;
    SQL
  end

  def down
    execute <<-SQL
      DROP SEQUENCE inquiry_number_seq;
    SQL
  end
end
