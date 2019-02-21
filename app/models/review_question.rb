class ReviewQuestion < ApplicationRecord
  include Mixins::CanBeStamped

  enum question_type: {
      'Logistics': 10,
      'Sales': 20,
  }
  validates_presence_of :question_type
  validate :weightage_requirement

  scope :sales, -> { where(question_type: :'Sales') }
  scope :logistics, -> { where(question_type: :'Logistics') }

  def to_s
    self.question
  end

  def max_weightage
    if self.id.present?
      current_weightage = ReviewQuestion.find(self.id).weightage
      (100 - (ReviewQuestion.where(question_type: self.question_type).pluck(:weightage).sum - current_weightage)).to_i
    end
  end

  def self.overall_weightage(type = 'Logistics')
    ReviewQuestion.where(question_type: type).pluck(:weightage).sum
  end

  private

    def weightage_requirement
      if self.id.present? && self.weightage > self.max_weightage
        errors.add(:weightage, "of all #{self.question_type} review question must be less than 100, for current question it should be max #{self.max_weightage}")
      end
    end
end
