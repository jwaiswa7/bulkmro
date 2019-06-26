class TargetPeriod < ApplicationRecord
  has_many :annual_targets

  validates_presence_of :period_month
end
