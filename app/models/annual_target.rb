class AnnualTarget < ApplicationRecord
  belongs_to :overseer, required: false
  belongs_to :account, required: false
  belongs_to :resource, polymorphic: true
  belongs_to :manager, class_name: 'Overseer', foreign_key: :manager_id, required: false
  belongs_to :business_head, class_name: 'Overseer', foreign_key: :business_head_id, required: false
  has_many :targets
  has_many :account_targets

  # validates_uniqueness_of :year, scope: :overseer_id

  # validates_presence_of :inquiry_target

  enum resource_type: {
      'Overseer': 1,
      'Account': 2,
  }

  def self.year_range
    initial_year = 2019
    years = {}
    (initial_year..Date.today.year).each do |year|
      years["#{year}-#{year + 1}"] = "#{year}-#{year + 1}"
    end
    years
  end

  def monthly_target(type)
    (self["#{type}_target"]) / 12.0
  end

  def self.current_year
    current = Date.today.year
    "#{current}-#{current + 1}"
  end

  def disabled_status(target_type)
    (self[target_type] != 0.0)
  end
end
