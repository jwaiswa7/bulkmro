class Contact < ApplicationRecord
  include Mixins::IsAPerson
  include Mixins::CanBeStamped

  pg_search_scope :locate, :against => [:first_name, :last_name], :associated_against => { }, :using => { :tsearch => {:prefix => true} }

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

  validates_uniqueness_of :remote_uid, :allow_blank => true, :allow_nil => true

  enum role: { admin: 10 }
  enum status: { active: 10, inactive: 20 }
  enum contact_group: {
      general: 10,
      company_top_manager: 20,
      retailer: 30,
      ador: 40,
      vmi_group: 50,
      c_form_customer_group: 60,
      manager: 70,
  }

  after_initialize :set_defaults, :if => :new_record?
  def set_defaults
    self.role ||= :admin
    self.status ||= :active
    self.contact_group ||= :general

    if self.company.present?
      self.account ||= self.company.account
    end
  end

  def self.legacy
    find_by_email('legacy@bulkmro.com')
  end
end
