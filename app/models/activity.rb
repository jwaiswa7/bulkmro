class Activity < ApplicationRecord
  REJECTIONS_CLASS = 'ActivityRejection'
  APPROVALS_CLASS = 'ActivityApproval'

  include Mixins::CanBeStamped
  include Mixins::CanBeApproved
  include Mixins::CanBeRejected
  include Mixins::HasApproveableStatus

  update_index('activities#activity') { self }
  pg_search_scope :locate, against: [:purpose, :company_type, :activity_type], associated_against: { created_by: [:first_name, :last_name], account: [:name], company: [:name], contact: [:first_name, :last_name], inquiry: [:inquiry_number] }, using: { tsearch: { prefix: true } }

  has_many :activity_overseers
  has_many :email_messages, dependent: :destroy
  has_many :overseers, through: :activity_overseers
  accepts_nested_attributes_for :activity_overseers, reject_if: lambda { |attributes| attributes['overseer_id'].blank? && attributes['id'].blank? }, allow_destroy: true
  belongs_to :inquiry, required: false
  belongs_to :company, required: false
  has_one :account, through: :company
  belongs_to :contact, required: false
  has_one :company_creation_request, dependent: :destroy, validate: false
  has_one :contact_creation_request, dependent: :destroy, validate: false
  accepts_nested_attributes_for :company_creation_request, reject_if: lambda { |attributes| attributes['name'].blank? }, allow_destroy: true
  accepts_nested_attributes_for :contact_creation_request, reject_if: lambda { |attributes| attributes['first_name'].blank? }, allow_destroy: true

  before_save :send_overdue_email, if: :will_save_change_to_activity_status?

  has_many_attached :attachments
  scope :with_includes, -> { includes(:company, :contact, :inquiry) }
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

  enum main_summary_status: {
      'Meeting': 10,
      'Phone call': 20,
      'Email': 30,
      'Quote/Tender Prep': 40,
  }, _suffix: true


  enum activity_status: {
    'Completed': 10 ,
    'Closed': 20 ,
    'Pending': 30 ,
    'Overdue': 40 ,
    'To-Do': 50 ,
    'MOM Sent': 60 ,
    'Customer follow-up email sent': 70 
  }
  scope :with_includes, -> { includes(:created_by, :company, :inquiry, :contact) }

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
    self.activity_date ||= Date.today
    self.activity_status ||= :'To-Do'
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

  def approval_status
    if self.approved?
      'Approved'
    elsif self.rejected?
      'Rejected'
    else
      'Pending Approval'
    end
  end

  def to_s
    (company || inquiry || contact).to_s
  end

  private 

  # will send an email to the user if the activity status changes to overdue
  def send_overdue_email 
    return true unless activity_status == "Overdue"
    # build email message
    emails = [contact&.email]
    overseers.map { |overseer| emails.push overseer.email }

    email_message = email_messages.build(
      subject: "Activity is overdue",
      to: emails,
      from: 'sales@bulkmro.com'
    )
    
    ActivityMailer.overdue(email_message).deliver_now if email_message.save
    
  end
end
