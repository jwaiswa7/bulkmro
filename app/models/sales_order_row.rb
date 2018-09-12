class SalesOrderRow < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :sales_order
  has_one :sales_quote, :through => :sales_order
  belongs_to :sales_quote_row
  has_one :inquiry_product, :through => :sales_quote_row

  delegate :unit_cost_price, :unit_selling_price, :margin_percentage, to: :sales_quote_row, allow_nil: true
  delegate :sr_no, to: :inquiry_product, allow_nil: true

  validates_presence_of :quantity
  validates_numericality_of :quantity, :less_than_or_equal_to => :maximum_quantity

  after_initialize :set_defaults, :if => :new_record?
  def set_defaults
    if self.sales_quote_row.present?
      self.quantity ||= maximum_quantity
    end
  end

  def maximum_quantity
    self.sales_quote_row.quantity if sales_quote_row.present?
  end
end
