class CompanyTransactionsAmount < ApplicationRecord
  belongs_to :company
  def increment_total_amount(amount)
    threshold_amount = (Settings.tcs.tcs_threshold).to_f
    total_amount = self.total_amount.to_f
    total_amount = total_amount + amount.to_f
    if total_amount >= threshold_amount
      self.update_attributes(total_amount: total_amount, amount_reached_to_date: Time.now)
    else
      self.update_attributes(total_amount: total_amount)
    end
  end

  def decrement_total_amount(amount)
    total_amount = self.total_amount - amount.to_f
    self.update_attributes(total_amount: total_amount)
  end
end
