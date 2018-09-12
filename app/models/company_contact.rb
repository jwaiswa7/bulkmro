class CompanyContact < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :company
  belongs_to :contact

  validates_uniqueness_of :contact, scope: :company

  def to_s
    self.contact.to_s
  end
end
