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

  def max_weightage
    (100 - ReviewQuestion.where(:question_type => self.question_type).pluck(:weightage).sum).to_i
  end

  private
  def weightage_requirement
    if self.weightage > self.max_weightage
      errors.add(:weightage, "of all #{self.question_type} review question must be less than 100, for current question it should be max #{self.max_weightage}")
    end
  end
end
