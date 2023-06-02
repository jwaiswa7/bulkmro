class CreateCustomerFeedbacks < ActiveRecord::Migration[5.2]
  def change
    create_table :customer_feedbacks do |t|
      t.string :customer_email
      t.integer :experience
      t.text :most_liked
      t.text :to_improve
      t.text :comments

      t.timestamps
    end
  end
end
