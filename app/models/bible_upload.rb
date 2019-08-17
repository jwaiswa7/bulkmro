class BibleUpload < ApplicationRecord
  include Mixins::CanBeStamped
  belongs_to :overseer, required: false
  has_many :bible_upload_logs, class_name: 'BibleUploadLog', dependent: :destroy

  has_one_attached :bible_attachment
end