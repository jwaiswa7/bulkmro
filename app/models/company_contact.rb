class CompanyContact < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :company
  belongs_to :contact

  validates_uniqueness_of :contact, scope: :company
end
