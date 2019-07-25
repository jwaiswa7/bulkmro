class TargetPeriod < ApplicationRecord
  has_many :annual_targets
  has_many :targets

  validates_presence_of :period_month

  def to_s
    self.period_month.strftime('%b %Y')
  end
end
