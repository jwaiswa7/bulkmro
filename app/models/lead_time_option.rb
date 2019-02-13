class LeadTimeOption < ApplicationRecord
  has_many :sales_quote_rows

  validates_presence_of :min_days, :name
  validates_uniqueness_of :name

  def self.default
    find_by_name('1-2 WEEKS')
  end
end
