class Task < ApplicationRecord

  after_initialize :set_default_status



  COMMENTS_CLASS = 'TaskComment'

  include Mixins::CanBeStamped
  include Mixins::HasComments

  has_many :task_overseers
  has_many :overseers, through: :task_overseers
  has_many_attached :attachments
  has_many :email_messages, dependent: :destroy
  accepts_nested_attributes_for :task_overseers, reject_if: lambda { |attributes| attributes['overseer_id'].blank? && attributes['id'].blank? }, allow_destroy: true
  belongs_to :company, class_name: 'Company', foreign_key: 'company_id', required: false

  EMAIL_FROM_ADDRESS = 'itop@bulkmro.com'


  update_index('tasks#task') { self }

  scope :with_includes, -> {}

  enum status: {
    'Completed': 10,
    'In-progress': 20,
    'Pending': 30,
    'Overdue': 40,
    'To-do': 50
  }

  enum priority: {
    'High': 10,
    'Medium': 20,
    'Low': 30
  }

  enum departments: {
    'Sales': 10,
    'Logistics': 20,
    'Procurement': 30,
    'Technology': 40,
    'Admin': 50,
    'Accounts': 60
  }

  def to_s
    "#{task_id}"
  end

  private

  def set_default_status
    self.status ||= :'To-do'
  end


end
