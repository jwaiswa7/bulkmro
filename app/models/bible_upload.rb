class BibleUpload < ApplicationRecord
  include Mixins::CanBeStamped

  has_many :bible_upload_logs, dependent: :destroy
  scope :with_includes, -> {}

  has_one_attached :file

  update_index('bible_uploads') {self}

  enum status: {
      'Pending': 10,
      'Processing': 20,
      'Completed': 30,
      'Completed with Errors': 40,
      'Failed': 50
  }

  enum import_type: {
      'Sales Order': 10,
      'Sales Invoice': 20
  }
end
