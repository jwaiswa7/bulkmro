

class CompanyContact < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :company
  has_one :as_default, dependent: :nullify, class_name: 'Company', inverse_of: :default_company_contact, foreign_key: :default_company_contact_id
  belongs_to :contact

  validates_uniqueness_of :contact, scope: :company

  def to_s
    self.contact.to_s
  end
end
