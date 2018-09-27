class Warehouse < ApplicationRecord
  include Mixins::HasVisibility

  belongs_to :address, required: true
  has_many :bill_from_inquiries, :inverse_of => :bill_from, foreign_key: :bill_from_id, class_name: 'Inquiry', dependent: :nullify
  has_many :ship_from_inquiries, :inverse_of => :ship_from, foreign_key: :ship_from_id, class_name: 'Inquiry', dependent: :nullify

  validates_presence_of :address
  validates_presence_of :name

  def self.default
    find_by_name('Mumbai - Lower Parel')
  end
end
