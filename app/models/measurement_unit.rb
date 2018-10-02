class MeasurementUnit < ApplicationRecord
  include Mixins::HasUniqueName

  has_many :products

  def self.default
    find_by_name('EA')
  end
end
