class PodRow < ApplicationRecord
  belongs_to :sales_invoice, required: false
  has_many_attached :attachments
end
