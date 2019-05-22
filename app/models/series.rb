class Series < ApplicationRecord
  after_save :create_first_number
  validates_numericality_of :last_number, less_than: ->(series) { series.first_number + 99999 }
  validates_numericality_of :last_number, greater_than: ->(series) { series.first_number - 1 }

  enum document_type: {
      'Sales Quotation': 1,
      'Sales Order': 2,
      'A/R Invoice': 3,
      'A/R Invoice Branch Transfer': 4,
      'A/R Deposit ( BG )': 5,
      'A/R Invoice Credit Memo': 6,
      'A/R Invoice Cancel': 7,
      'Delivery': 8,
      'A/R Invoice GST Debit Memo': 9,
      'Purchase Order': 10,
      'GRPO': 11,
      'A/P Invoice': 12,
      'A/P Invoice Branch Transfer': 13,
      'A/P Invoice Credit Memo': 14,
      'A/P Invoice GST Debit Memo': 15,
      'Incoming Payments': 16,
      'Down Payment Request': 17,
      'Outgoing Payments': 18,
      'Journal Vouchers': 19,
      'Inventory Transfer Request': 20,
      'Inventory Transfer': 21
  }

  def create_first_number
    if self.saved_change_to_series? || self.saved_change_to_number_length?
      series = self.series
      number_length = self.number_length
      self.first_number = (series.to_s + '0' * (number_length - series.digits.count)).to_i + 1
      self.save
    end
  end

  def increment_last_number
    self.update_attributes(last_number: (self.last_number || self.first_number) + 1)
  end

end

# s = Series.create(:document_type => 2,:series => 102, :series_name => 'LWP 2019', :period_indicator => 'FY2019-20', :number_length => 9)