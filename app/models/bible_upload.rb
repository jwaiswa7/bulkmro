class BibleUpload < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :overseer, required: false
  has_many :bible_upload_logs, class_name: 'BibleUploadLog', dependent: :destroy

  has_one_attached :file

  enum status: {
      'Pending': 10,
      'Processing': 20,
      'Completed': 30,
      'Failed': 40
  }

  enum import_type: {
      'Sales Order': 10,
      'Sales Invoice': 20
  }
end