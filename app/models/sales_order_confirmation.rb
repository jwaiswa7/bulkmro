

class SalesOrderConfirmation < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :sales_order
end
