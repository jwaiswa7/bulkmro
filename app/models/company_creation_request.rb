class CompanyCreationRequest < ApplicationRecord
  belongs_to :activity
  belongs_to :account
  has_one :company
  validates_presence_of :name

  enum :account_type => {
      :is_supplier => 10,
      :is_customer => 20,
  }

end