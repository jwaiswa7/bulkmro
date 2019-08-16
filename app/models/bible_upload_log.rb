class BibleUploadLog < ApplicationRecord
  belongs_to :bible_file_upload,  class_name: 'BibleFileUpload', required: false
end
