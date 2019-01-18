class CompanyReview < ApplicationRecord
  include Mixins::CanBeStamped

  has_many :company_ratings, dependent: :destroy
  accepts_nested_attributes_for :company_ratings, allow_destroy: true
  belongs_to :rateable, polymorphic: true

  enum survey_type:{
    :'Logistics' => 10,
    :'Sales' => 20
  }

  scope :sales, ->{ where(survey_type: :'Sales')}
  scope :logistics, ->{ where(survey_type: :'Logistics')}
  scope :reviewed, ->(overseer, type){where(survey_type: type, created_by: overseer).where.not(rating: nil)}
end
