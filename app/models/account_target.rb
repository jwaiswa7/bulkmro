class AccountTarget < ApplicationRecord
  belongs_to :target_period, required: true
  belongs_to :annual_target, required: true
  belongs_to :account, required: true

  validates_presence_of :target_value
end
