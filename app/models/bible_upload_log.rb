class BibleUploadLog < ApplicationRecord
  belongs_to :bible_upload,  class_name: 'BibleUpload', required: false
end
