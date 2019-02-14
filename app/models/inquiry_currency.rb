

class InquiryCurrency < ApplicationRecord
  belongs_to :currency
  has_one :inquiry

  validates_presence_of :conversion_rate
  validates_numericality_of :conversion_rate, minimum: 1, maximum: 1000

  after_initialize :set_defaults, if: :new_record?

  delegate :sign, to: :currency
  def set_defaults
    self.currency ||= Currency.inr

    if self.currency.present?
      self.conversion_rate ||= self.currency.conversion_rate
    end
  end
end
