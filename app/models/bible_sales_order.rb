class BibleSalesOrder < ApplicationRecord
  belongs_to :company
  belongs_to :account
  belongs_to :sales_order, required: false
  belongs_to :inside_sales_owner, class_name: 'Overseer', foreign_key: 'inside_sales_owner_id', required: false
  belongs_to :outside_sales_owner, class_name: 'Overseer', foreign_key: 'outside_sales_owner_id', required: false

  def has_final_sales_quote?
    1
  end

  def total_quote_value

  end

end
