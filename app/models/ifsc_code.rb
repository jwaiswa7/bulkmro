class IfscCode < ApplicationRecord
  has_many :company_banks
  belongs_to :bank

  scope :with_includes, -> {  }

  def to_s
    ["IFSC Code", " ##{self.id}"].join
  end
end
