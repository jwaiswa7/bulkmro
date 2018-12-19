class CartItem < ApplicationRecord
  belongs_to :customer_product
  belongs_to :product
  belongs_to :cart
  delegate :best_tax_rate, to: :customer_product

  validates_presence_of :quantity

  after_initialize :set_defaults, :if => :new_record?

  def set_defaults
    self.quantity ||= 1
  end

end