class PackingSlipRow < ApplicationRecord
  belongs_to :packing_slip, default: false
  belongs_to :ar_invoice_request_row, default: false

end
