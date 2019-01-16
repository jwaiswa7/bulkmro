class ReviewQuestion < ApplicationRecord
  include Mixins::CanBeStamped

  enum :question_type => {
      :'Logistics' => 10,
      :'Sales' => 20,
  }
  validates_presence_of :question_type

  scope :sales, ->{ where(question_type: :'Sales')}
  scope :logistics, ->{ where(question_type: :'Logistics')}

  def to_s
    self.question
  end
end
