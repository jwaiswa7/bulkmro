class PaymentCollection < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :account, required: false
  belongs_to :company, required: false

  def overdue_outstanding_amount
    self.amount_received_fp_od + self.amount_received_pp_od + self.amount_received_npr_od
  end
end