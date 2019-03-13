class Kit < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::CanBeSynced

  default_scope { order(created_at: :desc) }

  pg_search_scope :locate, against: [:remote_uid], associated_against: { product: [:sku, :name], inquiry: [:inquiry_number] }, using: { tsearch: { prefix: true } }

  has_many :kit_product_rows
  belongs_to :product
  belongs_to :inquiry

  accepts_nested_attributes_for :product
  accepts_nested_attributes_for :kit_product_rows, reject_if: lambda { |attributes| attributes['product_id'].blank? && attributes['id'].blank? }, allow_destroy: true
  accepts_nested_attributes_for :inquiry, reject_if: lambda { |attributes| attributes['inquiry_number'].blank? }, allow_destroy: true
  # delegate :quantity, :to => :sales_quote_row
end
