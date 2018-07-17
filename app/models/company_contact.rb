class CompanyContact < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :company
  belongs_to :contact
end
