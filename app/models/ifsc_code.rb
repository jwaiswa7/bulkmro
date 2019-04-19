class IfscCode < ApplicationRecord
  has_many :company_banks
  belongs_to :bank

  scope :with_includes, -> {  }
end
