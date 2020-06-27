class DcRow < ApplicationRecord
  belongs_to :delivery_challan, class_name: 'DeliveryChallan'
  belongs_to :sales_order_row, class_name: 'SalesOrderRow'

  validates_numericality_of :quantity, greater_than: 0, allow_nil: true
  delegate :converted_unit_selling_price, to: :sales_order_row, allow_nil: true
  delegate :best_tax_code, to: :sales_order_row, allow_nil: true
  delegate :best_tax_rate, to: :sales_order_row, allow_nil: true
  delegate :unit_selling_price, to: :sales_order_row, allow_nil: true
  delegate :unit_selling_price_with_tax, to: :sales_order_row, allow_nil: true

end