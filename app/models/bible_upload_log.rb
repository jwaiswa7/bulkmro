class BibleUploadLog < ApplicationRecord
  belongs_to :bible_upload

  enum status: {
      'Success': 10,
      'Failed': 20
  }

end
