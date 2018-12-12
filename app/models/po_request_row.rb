class PoRequestRow < ApplicationRecord
  belongs_to :po_request
  belongs_to :sales_order_row
end
