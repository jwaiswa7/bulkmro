class PaymentCollection < ApplicationRecord
  belongs_to :account, required: false
  belongs_to :company, required: false
end
