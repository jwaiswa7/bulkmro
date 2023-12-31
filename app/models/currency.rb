# frozen_string_literal: true

class Currency < ApplicationRecord
  has_many :inquiry_currencies
  has_many :figures, class_name: 'CurrencyRate'
  has_one :current_rate, -> { today }, class_name: 'CurrencyRate'

  scope :non_inr, -> { where.not(id: inr.id) }

  validates_presence_of :conversion_rate
  validates_numericality_of :conversion_rate, minimum: 1, maximum: 1000

  def sign
    if name == 'USD'
      '$'
    elsif name == 'EUR'
      '€'
    elsif name == 'LEI'
      'L'
    else
      '₹'
    end
  end

  def self.inr
    find_by_name('INR')
  end

  def self.usd
    find_by_name('USD')
  end

  def self.lei
    find_by_name('LEI')
  end

  def self.eur
    find_by_name('EUR')
  end
end
