class CompanyReview < ApplicationRecord
  include Mixins::CanBeStamped
  pg_search_scope :locate, against: [:rating], associated_against: { created_by: [:first_name, :last_name], company: [:name],  }, using: { tsearch: { prefix: true } }

  belongs_to :company
  has_many :company_ratings, dependent: :destroy
  accepts_nested_attributes_for :company_ratings, allow_destroy: true
  belongs_to :rateable, polymorphic: true
  ratyrate_rateable "CompanyRating"
  validates_associated :company_ratings

  enum survey_type: {
    'Logistics': 10,
    'Sales': 20
  }

  scope :sales, -> { where(survey_type: :'Sales') }
  scope :logistics, -> { where(survey_type: :'Logistics') }
  scope :reviewed, ->(overseer, type) { where(survey_type: type, created_by: overseer).where.not(rating: nil) }
end
