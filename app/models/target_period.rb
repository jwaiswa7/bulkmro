class TargetPeriod < ApplicationRecord
  has_many :annual_targets
  has_many :targets

  validates_presence_of :period_month
end
