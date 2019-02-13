

class PoRequestRow < ApplicationRecord
  belongs_to :po_request
  belongs_to :sales_order_row
  has_one :sales_quote_row, through: :sales_order_row
  has_one :inquiry_product_supplier, through: :sales_quote_row
  has_one :inquiry_product, through: :inquiry_product_supplier
  has_one :product, through: :inquiry_product
end
