# frozen_string_literal: true

class TargetPeriod < ApplicationRecord
  has_many :targets

  validates_presence_of :period_month
end
