

class Industry < ApplicationRecord
  include Mixins::HasUniqueName
  include Mixins::CanBeSynced
end
