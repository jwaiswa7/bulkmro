class ImageReader < ApplicationRecord
  validates_uniqueness_of :reference_id
  validates_uniqueness_of :flu_id, allow_blank: true

  has_paper_trail on: []

  enum status: {
      successful: 10,
      failed: 20,
      pending: 30,
      completed: 40
  }
end
