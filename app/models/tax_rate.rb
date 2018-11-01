class TaxRate < ApplicationRecord
  has_many :products
  has_many :categories
  has_many :sales_quotes_rows

  def self.default
    find_by_tax_percentage(18.0)
  end

  def to_s
    self.tax_percentage ? "GST #{self.tax_percentage}%" : ' GST N/A'
  end
end
