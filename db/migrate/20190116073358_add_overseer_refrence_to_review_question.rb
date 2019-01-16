class AddOverseerRefrenceToReviewQuestion < ActiveRecord::Migration[5.2]
  def change
    add_reference :review_questions, :overseer, foreign_key: true
  end
end
