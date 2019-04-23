class ArInvoice < ApplicationRecord
  include Mixins::CanBeStamped

  has_and_belongs_to_many :sales_orders

end
