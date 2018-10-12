class AddInquiryNumberSequenceToInquiry < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      ALTER SEQUENCE inquiry_number_seq OWNED BY inquiries.inquiry_number;
      ALTER TABLE inquiries ALTER COLUMN inquiry_number SET DEFAULT nextval('inquiry_number_seq');
    SQL
  end

  def down
    execute <<-SQL
      ALTER SEQUENCE IF EXISTS inquiry_number_seq OWNED BY NONE;
      ALTER TABLE inquiries ALTER COLUMN inquiry_number SET NOT NULL;
    SQL
  end
end
