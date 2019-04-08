class AverageCache < ActiveRecord::Base
  belongs_to :rater, class_name: 'Overseer'
  belongs_to :rateable, polymorphic: true
end
