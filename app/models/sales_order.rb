class SalesOrder < ApplicationRecord
  belongs_to :sales_quote
end
