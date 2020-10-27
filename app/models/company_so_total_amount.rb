class CompanySoTotalAmount < ApplicationRecord
  belongs_to :company

  def increment_total_amount(so_amount)
    amount = 5000000.0
    so_total_amount = self.so_total_amount.to_f
    total_amount = so_total_amount + so_amount.to_f
    if so_total_amount < amount && total_amount > amount
      self.update_attributes(so_total_amount: total_amount, amount_reached_to_date: Time.now)
    else
      self.update_attributes(so_total_amount: total_amount)
    end
  end

  def decrement_total_amount(so_amount)
    total_amount = self.so_total_amount - so_amount.to_f
    self.update_attributes(so_total_amount: total_amount)
  end
end
