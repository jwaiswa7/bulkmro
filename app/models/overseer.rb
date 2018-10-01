require 'mail'

class Overseer < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::IsAPerson

  has_many :activities, foreign_key: :created_by_id
  has_one_attached :file

  pg_search_scope :locate, :against => [:first_name, :last_name, :email], :associated_against => { }, :using => { :tsearch => {:prefix => true} }
  has_closure_tree({ name_column: :to_s })

  # Include default devise modules. Others available are:
  # :confirmable, :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable, :omniauthable, omniauth_providers: %i[google_oauth2]

  enum role: { admin: 10, sales: 20, sales_manager: 30 }
  enum status: { active: 10, inactive: 20 }

  validates_presence_of :email
  validates_presence_of :password, :if => :new_record?
  validates_presence_of :password_confirmation, :if => :new_record?

  after_initialize :set_defaults, :if => :new_record?
  def set_defaults
    self.role ||= :sales
    self.status ||= :active
  end

  def hierarchy_to_s
    ancestry_path.join(' > ')
  end

  def self.from_omniauth(access_token)
    data = access_token.info
    email = data['email']
    domain = Mail::Address.new(email).domain

    if domain.in? %w(bulkmro.com)
      password = Devise.friendly_token[0, 20]

      overseer = Overseer.where(email: data['email']).first_or_create do |overseer|
        overseer.password_confirmation = password
        overseer.password = password
        overseer.first_name = data['first_name']
        overseer.last_name = data['last_name']
        overseer.google_oauth2_uid = data['uid']
        overseer.username = "none"
      end

      overseer.update_attributes(:username => 'nousername') if overseer.username.blank?
      overseer.update_attributes(:google_oauth2_metadata => data)
      overseer
    end
  end

  def can_send_emails?
    self.smtp_password.present?
  end

  def cannot_send_emails?
    !can_send_emails?
  end

  def self.default
    find_by_email('ashwin.goyal@bulkmro.com')
  end
end
