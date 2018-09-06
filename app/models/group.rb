class Group < ApplicationRecord
	#include Mixins::CanBeStamped
  #include Mixins::HasUniqueName

  has_many :contacts
end
