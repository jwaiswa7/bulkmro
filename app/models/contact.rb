class Contact < ApplicationRecord
  include Mixins::IsAPerson
  include Mixins::CanBeStamped
  include Mixins::CanBeSynced
  include Mixins::HasMobileAndTelephone

  pg_search_scope :locate, :against => [:first_name, :last_name, :email], :associated_against => {:account => [:name]}, :using => {:tsearch => {:prefix => true}}

  # Include default devise modules. Others available are:
  # :confirmable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable

  belongs_to :account
  has_many :inquiries
  has_many :company_contacts
  has_many :companies, :through => :company_contacts
  accepts_nested_attributes_for :company_contacts
  has_one :company_contact
  has_one :company, :through => :company_contact
  has_one :cart
  has_many :customer_orders

  enum role: {customer: 10, account_manager: 20}
  enum status: {active: 10, inactive: 20}
  enum contact_group: {
      general: 10,
      company_top_manager: 20,
      retailer: 30,
      ador: 40,
      vmi_group: 50,
      c_form_customer_group: 60,
      manager: 70,
  }

  validates_presence_of :telephone, if: -> {!self.mobile.present? && not_legacy?}
  validates_presence_of :mobile, if: -> {!self.telephone.present? && not_legacy?}

  after_initialize :set_defaults, :if => :new_record?

  def set_defaults
    self.role ||= :customer
    self.status ||= :active
    self.contact_group ||= :general

    password = Devise.friendly_token[0, 20]
    self.password ||= password
    self.password_confirmation ||= password

    if self.company.present?
      self.account ||= self.company.account
    end
  end


  def self.legacy
    find_by_email('legacy@bulkmro.com')
  end

  def current_cart
    self.cart || self.create_cart
  end
end
