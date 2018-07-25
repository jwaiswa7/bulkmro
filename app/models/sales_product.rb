class SalesProduct < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::HasSupplier

  belongs_to :sales_quote
  belongs_to :product

  validates_uniqueness_of :product, scope: :sales_quote
  validates_presence_of :quantity, :unit_cost_price, :unit_sales_price
  validates_numericality_of :quantity, :greater_than_or_equal_to => 1
  validates_numericality_of :unit_cost_price, :unit_sales_price, :greater_than => 0

  after_initialize :set_defaults, :if => :new_record?

  def set_defaults
    self.quantity ||= 1
    self.margin ||= 15
  end
end
