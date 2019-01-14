class MaterialReadinessFollowup < ApplicationRecord
  COMMENTS_CLASS = 'MrfComment'

  include Mixins::HasComments

  belongs_to :purchase_order
  belongs_to :logistics_owner, -> (record) {where(:role => 'logistics')}, :class_name => 'Overseer', foreign_key: 'logistics_owner_id'
  has_many :mrf_rows
  has_many_attached :attachments

  accepts_nested_attributes_for :mrf_rows, reject_if: lambda {|attributes| attributes['id'].blank?}, allow_destroy: true

  enum type_of_doc: {
      tax_invoice: 10,
      proforma_invoice: 20
  }

  enum status: {
      :'Material Pickup' => 10,
      :'Material Delivered' => 20
  }, _prefix: true
end
