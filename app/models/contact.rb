class Contact < ApplicationRecord
  include Mixins::IsAPerson
  include Mixins::CanBeStamped

  # Include default devise modules. Others available are:
  # :confirmable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable

  belongs_to :account
  has_many :inquiries
  has_many :company_contacts
  has_many :companies, :through => :company_contacts
  accepts_nested_attributes_for :company_contacts

  enum role: { admin: 10 }

  after_initialize :set_defaults, :if => :new_record?
  def set_defaults
    self.role ||= :admin
  end
end
