class AnnualTarget < ApplicationRecord

  belongs_to :overseer, required: true
  belongs_to :manager, class_name: 'Overseer', foreign_key: :manager_id, required: false
  belongs_to :business_head, class_name: 'Overseer', foreign_key: :business_head_id, required: false

  validates_uniqueness_of :year, :scope => :overseer_id

  validates_presence_of :inquiry_target

  after_initialize :set_defaults, if: :new_record?

  def set_defaults
    self.manager_id = self.overseer.parent
  end

  def self.year_range
    initial_year = 2019
    years = {}
    (initial_year..Date.today.year).each do |year|
      years["#{year}-#{year+1}"] = "#{year}-#{year+1}"
    end
    years
  end

  def monthly_target(type)
    (self["#{type}_target"]) / 12.0
  end

end
