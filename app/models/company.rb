class Company < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :account
  belongs_to :default_payment_option, class_name: 'PaymentOption', foreign_key: :default_payment_option_id
  has_many :company_contacts
  has_many :contacts, :through => :company_contacts
  accepts_nested_attributes_for :company_contacts
  has_many :company_brands
  has_many :brands, :through => :company_brands
  accepts_nested_attributes_for :company_brands
  has_many :products, :through => :brands
  has_many :inquiries
  has_many :addresses

  validates_presence_of :name
  validates_uniqueness_of :name
end
