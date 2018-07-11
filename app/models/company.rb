class Company < ApplicationRecord
  belongs_to :account
  belongs_to :default_payment_option, class_name: 'PaymentOption', foreign_key: :default_payment_option_id
  has_many :company_contacts
  has_many :contacts, :through => :company_contacts
  has_many :brands
  has_many :products, :through => :brands
  has_many :inquiries
end
