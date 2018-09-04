class SalesOrder < ApplicationRecord
  belongs_to :sales_quote
  has_many :rows, class_name: 'SalesOrderRow', inverse_of: :sales_order
  has_many :sales_quote_rows, :through => :sales_quote
end
