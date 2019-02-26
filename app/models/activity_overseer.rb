# frozen_string_literal: true

class ActivityOverseer < ApplicationRecord
  belongs_to :overseer
  belongs_to :activity

  validates_presence_of :overseer, :activity
  validates_uniqueness_of :overseer, scope: :activity
end
