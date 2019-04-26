class MaterialDispatch < ApplicationRecord
  belongs_to :ar_invoice, default: false
  belongs_to :sales_order, default: false
  has_many :packing_slips
end
