class RenameTypeToQuestionType < ActiveRecord::Migration[5.2]
  def change
    rename_column :review_questions, :type, :question_type

  end
end
