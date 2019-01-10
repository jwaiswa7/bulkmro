class AccountCreationRequest < ApplicationRecord
	belongs_to :activity

	enum :account_type => {
      :is_supplier => 10,
      :is_customer => 20,
  	}

  	validates_presence_of :account_type
end
