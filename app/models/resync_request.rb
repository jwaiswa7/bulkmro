# frozen_string_literal: true

class ResyncRequest < ApplicationRecord
  scope :initiated_today, -> { where(created_at: Date.today.beginning_of_day..Date.today.end_of_day).initiated }

  enum status: {
      addressed: 10,
      initiated: 20
  }
end
