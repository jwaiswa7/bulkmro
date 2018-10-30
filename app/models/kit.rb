class Kit < ApplicationRecord
  belongs_to :product

  delegate :quantity, :to => :sales_quote_row
end
