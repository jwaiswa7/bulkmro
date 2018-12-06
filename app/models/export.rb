class Export < ApplicationRecord

  has_one_attached :report

  enum export_type: {
      inquiries: 1,
      products: 5
  }
end
