class Task < ApplicationRecord

  include Mixins::CanBeStamped

  has_many :task_overseers
  has_many :overseers, through: :task_overseers
  has_many_attached :attachments
  accepts_nested_attributes_for :task_overseers, reject_if: lambda { |attributes| attributes['overseer_id'].blank? && attributes['id'].blank? }, allow_destroy: true
  belongs_to :company, class_name: 'Company', foreign_key: 'company_id', required: false



  update_index('tasks#task') { self }

  scope :with_includes, -> {}

  enum status: {
    'To-do': 10,
    'In-progress': 20,
    'Pending': 30,
    'Overdue': 40,
    'Completed': 50
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

end
