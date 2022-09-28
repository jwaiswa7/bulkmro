class IfscCode < ApplicationRecord
  has_many :company_banks
  belongs_to :bank

  update_index('ifsc_codes#ifsc_code') { self }
  scope :with_includes, -> { includes(:bank) }

  def to_s
    ['IFSC Code', " ##{self.id}"].join
  end
end
