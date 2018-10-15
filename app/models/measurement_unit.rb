class MeasurementUnit < ApplicationRecord
  include Mixins::HasUniqueName

  pg_search_scope :locate, :against => [:name], :associated_against => { }, :using => { :tsearch => {:prefix => true} }

  has_many :products

  def self.default
    find_by_name('EA')
  end
end
