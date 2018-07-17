class Rfq < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :supplier, class_name: 'Company', foreign_key: :supplier_id
  belongs_to :inquiry
end
