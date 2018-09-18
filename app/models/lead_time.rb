class LeadTime < ApplicationRecord

  validates_presence_of :min, :description
  validates_uniqueness_of :description

end
