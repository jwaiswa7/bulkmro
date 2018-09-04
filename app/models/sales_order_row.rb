class SalesOrderRow < ApplicationRecord
  belongs_to :sales_order
  belongs_to :sales_quote_row
end
