class PoRequestProduct < ApplicationRecord
  belongs_to :po_request
  belongs_to :sales_quote_row
  belongs_to :sales_order_row
  belongs_to :product
end
