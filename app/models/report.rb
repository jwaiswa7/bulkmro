class Report < ApplicationRecord
  pg_search_scope :locate, against: [:name, :uid], associated_against: {}, using: { tsearch: { prefix: true } }

  validates_date :start_at
  validates_date :end_at, after: :start_at

  attr_accessor :filters

  enum date_range: {
      custom: 10,
      this_month: 20,
      today: 30,
      last_week: 40,
      last_month: 50
  }, _prefix: true

  validates_presence_of :name
  validates_uniqueness_of :name

  after_initialize :set_global_defaults

  def set_global_defaults
    self.start_at = Time.now.beginning_of_month
    self.end_at = Time.now.end_of_month
    self.date_range = :custom
  end

  def self.activity
    where(name: 'ActivityReport').first_or_create do |report|
      report.uid = 'activity_report'
    end
  end

  def self.pipeline
    where(name: 'PipelineReport').first_or_create do |report|
      report.uid = 'pipeline_report'
    end
  end


  def self.target
    where(name: 'TargetReport').first_or_create do |report|
      report.uid = 'target_report'
    end
  end

  def self.monthly_sales
    where(name: 'MonthlySalesReport').first_or_create do |report|
      report.uid = 'monthly_sales_report'
    end
  end

  def start_date
    start_at.to_date
  end

  def end_date
    end_at.to_date
  end

  def start_month
    start_at.strftime('%B, %Y')
  end

  def end_month
    end_at.strftime('%B, %Y')
  end

  def to_param
    uid
  end

  attr_accessor :daterange
end
