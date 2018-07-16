class Inquiry < ApplicationRecord
  belongs_to :contact
  belongs_to :company

  has_many :quotes
  has_many :rfqs

end
