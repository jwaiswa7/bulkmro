class ReviewQuestion < ApplicationRecord
  include Mixins::CanBeStamped

  enum :question_type => {
      :is_sale => 10,
      :is_logistic => 20,
  }
  validates_presence_of :question_type

  after_initialize :set_defaults, :if => :new_record?
  def set_defaults
    self.question_type ||= :is_sale
  end
end
