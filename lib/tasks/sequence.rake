namespace :sequence do
  desc 'TODO'
  task inquiry: :environment do
    if Inquiry.maximum(:inquiry_number).present?
      default = Inquiry.maximum(:inquiry_number).to_i
      ActiveRecord::Base.connection.execute("ALTER SEQUENCE inquiry_number_seq START with #{(default + 1).to_i} RESTART;")
      ActiveRecord::Base.connection.execute("ALTER TABLE inquiries ALTER COLUMN inquiry_number SET DEFAULT nextval('inquiry_number_seq');")
    else
      puts 'To perform this task your database must have a max Id'
    end
  end

  task disable: :environment do
    ActiveRecord::Base.connection.execute("
      ALTER TABLE inquiries ALTER COLUMN inquiry_number SET NOT NULL;
    ")
  end

  task enable: :environment do
  end
end
