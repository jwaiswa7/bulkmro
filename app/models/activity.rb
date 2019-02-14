

class Activity < ApplicationRecord
  REJECTIONS_CLASS = 'ActivityRejection'
  APPROVALS_CLASS = 'ActivityApproval'

  include Mixins::CanBeStamped
  include Mixins::CanBeApproved
  include Mixins::CanBeRejected
  include Mixins::HasApproveableStatus

  pg_search_scope :locate, against: [:purpose, :company_type, :activity_type], associated_against: { created_by: [:first_name, :last_name], account: [:name], company: [:name], contact: [:first_name, :last_name], inquiry: [:inquiry_number] }, using: { tsearch: { prefix: true } }

  has_many :activity_overseers
  has_many :overseers, through: :activity_overseers
  accepts_nested_attributes_for :activity_overseers, reject_if: lambda { |attributes| attributes['overseer_id'].blank? && attributes['id'].blank? }, allow_destroy: true
  belongs_to :inquiry, required: false
  belongs_to :company, required: false
  has_one :account, through: :company
  belongs_to :contact, required: false
  has_one :company_creation_request, dependent: :destroy, validate: false
  accepts_nested_attributes_for :company_creation_request, reject_if: lambda { |attributes| attributes['name'].blank? }, allow_destroy: true

  has_many_attached :attachments

  enum company_type: {
      is_supplier: 10,
      is_customer: 20
  }

  enum purpose: {
      'First Meeting/Intro Meeting': 10,
      'Follow up': 20,
      'Negotiation': 30,
      'Closure': 40,
      'Others': 50,
  }

  enum activity_type: {
      'Meeting': 10,
      'Phone call': 20,
      'Email': 30,
      'Quote/Tender Prep': 40,
      'Tender preparation': 50
  }

  enum activity_status: {
      'Approved': 10,
      'Pending Approval': 20,
      'Rejected': 30
  }

  scope :not_meeting, -> { where.not(activity_type: activity_types[:'Meeting']) }
  scope :meeting, -> { where(activity_type: activity_types[:'Meeting']) }


  validates_presence_of :company_type
  validates_presence_of :purpose
  validates_presence_of :activity_type

  after_initialize :set_defaults, if: :new_record?

  def set_defaults
    self.company_type ||= :is_customer
    self.purpose ||= :'First Meeting/Intro Meeting'
    self.activity_type ||= :'Meeting'
    self.activity_date = Date.today
  end

  def activity_company
    if self.company.present?
      self.company
    elsif self.inquiry.present?
      self.inquiry.company
    end
  end

  def activity_account
    if self.account.present?
      self.account
    elsif self.inquiry.present?
      self.inquiry.account
    end
  end

  def to_s
    (company || inquiry || contact).to_s
  end
end
