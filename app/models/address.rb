class Address < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :company
  validates_presence_of :name
end
