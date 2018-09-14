class Currency < ApplicationRecord
  has_many :inquiry_currencies

  validates_presence_of :conversion_rate
  validates_numericality_of :conversion_rate, minimum: 1, maximum: 1000

  def self.base_currency
    find_by_name('INR')
  end

  def self.inr
    base_currency
  end

  def self.usd
    find_by_name('USD')
  end

  def self.eur
    find_by_name('EUR')
  end
end
