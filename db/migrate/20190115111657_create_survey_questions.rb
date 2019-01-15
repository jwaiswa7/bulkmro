class CreateSurveyQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :survey_questions do |t|
      t.string :question
      t.decimal :weightage
      t.integer :rating, default: 5
      t.timestamps
    end
  end
end
