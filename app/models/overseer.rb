require 'mail'

class Overseer < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::CanBeSynced
  include Mixins::IsAPerson
  include Mixins::HasMobileAndTelephone
  include Mixins::HasRole

  has_many :activities, foreign_key: :created_by_id
  has_many :annual_targets
  has_many :targets
  has_one_attached :file

  pg_search_scope :locate, against: [:first_name, :last_name, :email], associated_against: {acl_role: [:role_name]}, using: {tsearch: {prefix: true}}
  has_closure_tree(name_column: :to_s)

  # Include default devise modules. Others available are:
  # :confirmable, :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable, :omniauthable, omniauth_providers: %i[google_oauth2]

  ratyrate_rater
  enum status: {active: 10, inactive: 20}

  scope :can_send_email, -> {where.not(smtp_password: nil)}
  scope :cannot_send_email, -> {where(smtp_password: nil)}
  scope :with_includes, -> {includes(:activities)}
  validates_presence_of :email
  validates_presence_of :password, if: :new_record?
  validates_presence_of :password_confirmation, if: :new_record?

  after_initialize :set_defaults, if: :new_record?

  def set_defaults
    self.role ||= :inside_sales_executive
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
        acl_role = AclRole.where(is_default: true).first
        overseer.password_confirmation = password
        overseer.password = password
        overseer.first_name = data['first_name']
        overseer.last_name = data['last_name']
        overseer.google_oauth2_uid = data['uid']
        overseer.username = 'none'
        overseer.acl_role = acl_role
        overseer.acl_resources = acl_role.role_resources
      end

      overseer.update_attributes(username: 'nousername') if overseer.username.blank?
      overseer.update_attributes(google_oauth2_metadata: data)
      overseer
    end
  end

  def can_send_emails?
    self.smtp_password.present? && (self.mobile.present? || self.telephone.present?)
  end

  def cannot_send_emails?
    !can_send_emails?
  end

  def self.default
    find_by_email('auditor@bulkmro.com')
  end

  def to_s
    [self.first_name, ' ', self.last_name.chars.first, '.'].join('')
  end

  def self.default_approver
    overseer = Overseer.where(email: 'approver@bulkmro.com').first_or_create do |overseer|
      overseer.first_name = 'SAP'
      overseer.last_name = 'Approver'
      overseer.password = 'bm@123'
      overseer.password_confirmation = 'bm@123'
    end

    overseer.save!
    overseer
  end

  def self.system_overseer
    overseer = Overseer.where(email: 'system@bulkmro.com').first_or_create do |overseer|
      overseer.first_name = 'system'
      overseer.last_name = ' '
      overseer.password = 123456
      overseer.password_confirmation = 123456
    end

    overseer.save!
    overseer
  end

  def self.all_roles
    AclRole.all
  end

  def set_monthly_target
    annual_target = self.annual_targets.last
    if annual_target.present?
      overseer_target_months = self.targets
      remaining_target_periods = TargetPeriod.where('id > ?', overseer_target_months.pluck(:target_period_id).last)
      monthly_target = ((annual_target['inquiry_target'] * 100000) / 12.0).round(2)
      changed_monthly_target = overseer_target_months.last.target_value

      remaining_target_periods.each do |remaining_target_period|
        target_start_date = remaining_target_period.period_month - 1.month
        target_end_date = (remaining_target_period.period_month - 1.day).end_of_day
        inquiries = Inquiry.where(outside_sales_owner_id: self.id, status: 'Order Won').where(created_at: target_start_date..target_end_date)
        total_target_achieved = 0
        inquiries.each do |inquiry|
          if inquiry.bible_sales_order_total.present? && inquiry.bible_sales_order_total != 0
            sales_order_total = inquiry.bible_sales_order_total
          else
            sales_order_total = (inquiry.sales_orders.approved.map { |so| so.calculated_total || 0 }.sum).to_f
          end
          p 'inquiry---------' + inquiry.inquiry_number.to_s
          p 'sales order total==================' + sales_order_total.to_s
          total_target_achieved += sales_order_total
        end
        p "----total_target_achieved----------#{total_target_achieved}--------------"
        remaining_target = ((changed_monthly_target).to_f - total_target_achieved)
        changed_monthly_target = ((monthly_target).to_f + remaining_target)
        target = Target.where(overseer_id: self.id, target_period_id: remaining_target_period.id, target_type: 'Inquiry').first_or_initialize(target_value: changed_monthly_target, manager_id: annual_target.manager_id, business_head_id: annual_target.business_head_id, annual_target_id: annual_target.id)
        target.save unless target.id.present?
      end
    end
  end

  def get_monthly_target(target_type, date_range = nil)
    if date_range.present? && date_range['date_range'].present?
      from = date_range['date_range'].split('~').first.to_date.strftime('%Y-%m-01')
      to = date_range['date_range'].split('~').last.to_date.strftime('%Y-%m-01')
      target_periods = TargetPeriod.where(period_month: from..to).pluck(:id)
    else
      from = "#{Date.today.year}-04-01"
      to = Date.today.strftime('%Y-%m-%d')
      target_periods = TargetPeriod.where(period_month: from..to).pluck(:id)
    end
    if self.targets.present?
      monthly_targets = self.targets.where(target_type: target_type, target_period_id: target_periods)
      monthly_targets.last.target_value.to_i if monthly_targets.present?
    else
      0
    end
  end

  def get_annual_target
    self.annual_targets.where(year: AnnualTarget.current_year).last
  end

  def self.inside_sales_executives
    Overseer.joins(:acl_role).where(acl_roles:{role_name: 'Inside Sales Executive'}, status: 'active')
  end
end
