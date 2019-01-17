class ReviewQuestion < ApplicationRecord
  include Mixins::CanBeStamped

  enum :question_type => {
      :'Logistics' => 10,
      :'Sales' => 20,
  }
  validates_presence_of :question_type
  validate :weightage_requirement

  scope :sales, ->{ where(question_type: :'Sales')}
  scope :logistics, ->{ where(question_type: :'Logistics')}

  def to_s
    self.question
  end

  private
  def weightage_requirement
    same_type_question = ReviewQuestion.where(:question_type => self.question_type)
    weightage_sum = same_type_question.pluck(:weightage).sum
    if (weightage_sum + self.weightage) > 100
      errors.add(:weightage, "of all #{self.question_type} review question must be less than 100")
    end
  end
end
