class CompanySoTotalAmount < ApplicationRecord
  belongs_to :company

  def increment_total_amount(so_amount)
    total_amount = self.so_total_amount + so_amount.to_f
    self.update_attributes(so_total_amount: total_amount)
  end

  def decrement_total_amount(so_amount)
    total_amount = self.so_total_amount - so_amount.to_f
    self.update_attributes(so_total_amount: total_amount)
  end
end
