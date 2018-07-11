class Rfq < ApplicationRecord
  belongs_to :supplier, class_name: 'Company', foreign_key: :supplier_id
  belongs_to :inquiry
end
