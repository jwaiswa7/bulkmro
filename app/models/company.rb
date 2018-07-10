class Company < ApplicationRecord
  belongs_to :account
  belongs_to :default_payment_term, class_name: 'PaymentTerm', foreign_key: :default_payment_term_id
end
