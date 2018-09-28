class Report < ApplicationRecord
  pg_search_scope :locate, :against => [:name, :uid], :associated_against => {}, :using => {:tsearch => {:prefix => true}}

  validates_date :start_at
  validates_date :end_at, :after => :start_at

  enum date_range: {
      :custom => 10,
      :this_month => 20,
      :today => 30,
      :last_week => 40,
      :last_month => 50
  }

  validates_presence_of :name
  validates_uniqueness_of :name

  after_initialize :set_global_defaults

  def set_global_defaults
    self.start_at = Time.now.beginning_of_month
    self.end_at = Time.now.end_of_month
    self.date_range = :custom
  end

  def self.activity
    find_by_name('ActivityReport')
  end

  def to_param
    uid
  end
end
