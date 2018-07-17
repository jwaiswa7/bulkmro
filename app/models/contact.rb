class Contact < ApplicationRecord
  include Mixins::HasName
  include Mixins::CanBeStamped

  belongs_to :account
  has_many :inquiries
  has_many :company_contacts
  has_many :companies, :through => :company_contacts
  accepts_nested_attributes_for :company_contacts
end
